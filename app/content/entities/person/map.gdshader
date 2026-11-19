shader_type spatial;
render_mode unshaded, cull_back;

// Composed map tiles, plus zone / GPS accuracy circles drawn on top.

uniform sampler2D map_texture : source_color, filter_linear;
uniform vec2 size_px = vec2(448.0, 304.0); // map size in map pixels
uniform float corner_radius_px = 12.0;
uniform bool dark_mode = false; // the vector map is drawn in Home Assistant's light colours

// The drawing can be for a slightly different view than the one shown (while it is
// dragged or zoomed and the next drawing is on its way): a view pixel p is at
// p * texture_scale + texture_offset in the drawing. Outside it, plain land shows.
uniform vec2 texture_offset = vec2(0.0);
uniform float texture_scale = 1.0;
uniform vec2 texture_size_px = vec2(448.0, 304.0);
uniform vec3 background : source_color = vec3(0.965, 0.949, 0.925);

// xy: centre in map pixels, z: radius in map pixels
uniform vec4 circles[8];
uniform vec4 circle_colors[8];
uniform int circle_count = 0;

void fragment() {
	vec2 p = UV * size_px;

	// Rounded corners
	vec2 q = abs(p - size_px * 0.5) - (size_px * 0.5 - vec2(corner_radius_px));
	if (length(max(q, 0.0)) > corner_radius_px) {
		discard;
	}

	vec2 uv = (p * texture_scale + texture_offset) / texture_size_px;
	vec3 color = background;
	if (uv.x >= 0.0 && uv.y >= 0.0 && uv.x <= 1.0 && uv.y <= 1.0) {
		color = texture(map_texture, uv).rgb;
	}

	// Dark map: invert the brightness but keep the hue (blue water, green parks),
	// a common way to theme light map tiles dark. Uses YIQ: Y is brightness.
	if (dark_mode) {
		mat3 to_yiq = mat3(vec3(0.299, 0.596, 0.211), vec3(0.587, -0.274, -0.523), vec3(0.114, -0.322, 0.312));
		mat3 to_rgb = mat3(vec3(1.0, 1.0, 1.0), vec3(0.956, -0.272, -1.106), vec3(0.621, -0.647, 1.703));
		vec3 yiq = to_yiq * color;
		yiq.x = mix(0.06, 0.8, 1.0 - yiq.x);
		yiq.yz *= 0.6; // calmer colours on the dark background
		color = clamp(to_rgb * yiq, 0.0, 1.0);
	}

	for (int i = 0; i < circle_count; i++) {
		float d = distance(p, circles[i].xy);
		float r = circles[i].z;
		if (d < r) {
			color = mix(color, circle_colors[i].rgb, circle_colors[i].a);
		}
		// Outline, ~1.5 map pixels wide
		float edge = 1.0 - smoothstep(0.0, 1.5, abs(d - r));
		color = mix(color, circle_colors[i].rgb, edge * 0.85);
	}

	ALBEDO = color;
}
