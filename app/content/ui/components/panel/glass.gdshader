shader_type spatial;

render_mode diffuse_burley, specular_schlick_ggx, blend_mix, cull_disabled, shadows_disabled;

// Draws a rounded rectangle with a border over the mesh's 0..1 UV square.
//
// All lengths are in meters of the mesh's own (object) space. The size of the
// UV square is measured per pixel from screen-space derivatives, so the border
// keeps the same width on any mesh size or curved/bent mesh (cylinders, arcs)
// as long as the UVs run along the shape. Node scale scales the border with it.
// For circles and pills, set corner_radius >= half the shorter side; it is
// clamped there.

group_uniforms Color;
uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 0.3);
uniform vec4 border_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 edge_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

group_uniforms Size;
uniform float border_size : hint_range(0.0, 0.05, 0.00001) = 0.0003;
uniform float border_fade_in : hint_range(0.0, 0.05, 0.00001) = 0.0015;
uniform float border_fade_out : hint_range(0.0, 0.05, 0.00001) = 0.0;
uniform float corner_radius : hint_range(0.0, 1.0, 0.0001) = 0.006;

group_uniforms Roughness;
uniform float roughness : hint_range(0.0, 1.0) = 0.3;
uniform float grain_amount : hint_range(0.0, 1.0) = 0.02;


// Signed distance to a rounded rectangle centred at the origin, negative inside.
float rounded_rectangle(vec2 position, vec2 half_size, float radius) {
	vec2 q = abs(position) - half_size + radius;
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
}

varying vec3 object_position;

void vertex() {
	object_position = VERTEX;
}

float SchlickFresnel(float u) {
	float m = 1.0 - u;
	float m2 = m * m;
	return m2 * m2 * m;
}

void fragment() {
	// Meters of surface per unit of U and V at this pixel: solve the screen-space
	// Jacobians of UV and the object-space position for dPos/dU and dPos/dV.
	vec2 duv_dx = dFdx(UV);
	vec2 duv_dy = dFdy(UV);
	vec3 dp_dx = dFdx(object_position);
	vec3 dp_dy = dFdy(object_position);
	float det = abs(duv_dx.x * duv_dy.y - duv_dx.y * duv_dy.x);
	vec2 uv_size = vec2(
		length(dp_dx * duv_dy.y - dp_dy * duv_dx.y),
		length(dp_dy * duv_dx.x - dp_dx * duv_dy.x)
	) / max(det, 1e-12);

	vec2 half_size = 0.5 * uv_size;
	float radius = min(corner_radius, min(half_size.x, half_size.y));
	float d = rounded_rectangle((UV - 0.5) * uv_size, half_size, radius);

	// Anti-aliasing: meters covered by one screen pixel across the edge. The
	// outer edge fades over that pixel instead of cutting off, and the border
	// line is kept at least one pixel wide (a hairline), so corners and the
	// line stay smooth and visible at a distance. Up close nothing changes.
	float pixel = max(length(vec2(dFdx(d), dFdy(d))), 1e-6);
	float edge_coverage = clamp(0.5 - d / pixel, 0.0, 1.0);
	float line_width = max(border_size, pixel);

	float VdotN = dot(VIEW, NORMAL);
	float fresnel = clamp(SchlickFresnel(VdotN), 0.0, 1.0);

	ALBEDO = border_color.xyz;
	ALPHA = 0.0;
	float border_width = line_width + border_fade_in + border_fade_out;

	bool inside = false;

	if (d >= -border_width && d <= 0.0) {
		// Border
		float fade_in = border_fade_in > 0.0 ? (d + border_width) / border_fade_in : 1.0;
		float fade_out = border_fade_out > 0.0 ? -d / border_fade_out : 1.0;
		float alpha = clamp(min(fade_in, fade_out), 0.0, 1.0);
		if (d < -(line_width + border_fade_out)) {
			// Inner Fade
			ALBEDO = mix(color, border_color, alpha).xyz;
			ALPHA = mix(color.w, border_color.w, alpha);
			inside = true;
		} else {
			// Outer Fade
			ALBEDO = border_color.xyz;
			ALPHA = mix(0.0, border_color.w, alpha);
		}
	} else if (d < -border_width) {
		// Inside
		ALBEDO = color.xyz;
		ALPHA = color.w;
		inside = true;
	}

	if (inside) {
		float a = mix(0.001, 1.0, ALPHA);
		ALPHA = mix(fresnel * edge_color.a, 1.0, a);
		ALBEDO = mix(edge_color.rgb * edge_color.a, ALBEDO.rgb, a);

		ROUGHNESS = roughness;
		SPECULAR = 0.5 * inversesqrt(ALPHA);

		float noise = (fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 2.0;

	    ALBEDO += noise * grain_amount;
	}

	ALPHA *= edge_coverage;
}
