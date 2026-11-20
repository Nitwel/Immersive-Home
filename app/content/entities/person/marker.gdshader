shader_type spatial;
render_mode unshaded, cull_back;

// Round marker with a border: shows a picture, or a flat colour for initials/icons.

uniform sampler2D picture : source_color, filter_linear;
uniform bool has_picture = false;
uniform vec4 color : source_color = vec4(0.949, 0.353, 0.22, 1.0);
uniform vec4 border_color : source_color = vec4(1.0);
uniform float border = 0.12; // fraction of the radius

void fragment() {
	float d = distance(UV, vec2(0.5)) * 2.0;
	if (d > 1.0) {
		discard;
	}

	vec3 c = has_picture ? texture(picture, UV).rgb : color.rgb;
	if (d > 1.0 - border) {
		c = border_color.rgb;
	}
	ALBEDO = c;
}
