shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float blur_amount: hint_range(0.0, 5.0, 0.1) = 2;

void fragment() {
	vec4 lod = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
	ALBEDO = lod.xyz;
}