shader_type spatial;

render_mode diffuse_burley, specular_schlick_ggx, blend_mix, cull_disabled, shadows_disabled;

group_uniforms Color;
uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 0.3);
uniform vec4 border_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 edge_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

group_uniforms Size;
uniform vec2 size = vec2(1.0, 1.0);
uniform float border_size: hint_range(0.0, 0.5) = 0.001;
uniform float border_fade_in: hint_range(0.0, 0.5) = 0.005;
uniform float border_fade_out: hint_range(0.0, 0.5) = 0.0;
uniform float corner_radius = 0.04;

group_uniforms Roughness;
uniform float roughness : hint_range(0.0, 1.0) = 0.3;
uniform float grain_amount : hint_range(0.0, 1.0) = 0.02;


float rectangle(vec2 position) {
	vec2 component_wise_edge_distance = abs(position) - (vec2(0.5, 0.5) * size + corner_radius * (size - 1.0));
	float outsideDistance = length(max(component_wise_edge_distance, 0));
    float insideDistance = min(max(component_wise_edge_distance.x, component_wise_edge_distance.y), 0);
    return outsideDistance + insideDistance;
}

float SchlickFresnel(float u) {
	float m = 1.0 - u;
	float m2 = m * m;
	return m2 * m2 * m;
}

void fragment() {

	float VdotN = dot(VIEW, NORMAL);
	float fresnel = clamp(SchlickFresnel(VdotN), 0.0, 1.0);

	ALBEDO = border_color.xyz;
	ALPHA = 0.0;
	float border_scale = 1.0 + 2.0 * corner_radius;
	float d = rectangle((UV - 0.5) * size * border_scale);
	float border_width = (border_size + border_fade_in + border_fade_out) * border_scale;

	bool inside = false;

	if (d >= corner_radius - border_width && d <= corner_radius) {
		// Border
		float rel_d = (d - corner_radius + border_width) / border_width;
		float alpha = min((rel_d / (border_fade_in * border_scale / border_width)), (1.0 - (rel_d)) / (border_fade_out * border_scale / border_width));
		if (d < corner_radius - (border_size + border_fade_out) * border_scale) {
			// Inner Fade
			ALBEDO = mix(color, border_color, alpha).xyz;
			ALPHA = mix(color.w, border_color.w, alpha);
			inside = true;
		} else {
			// Outer Fade
			ALBEDO = border_color.xyz;
			ALPHA = mix(0.0, border_color.w, alpha);
		}
	} else if (d < corner_radius - border_width ) {
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
}