shader_type spatial;

uniform vec4 albedo: source_color = vec4(1.0, 1.0, 1.0, 0.4);
uniform float fade_offset : hint_range(-0.1, 0.1, 0.001) = 0.0;
uniform float fade_sharpness : hint_range(0.0, 35.0, 0.01) = 15.00;

varying vec3 vertex_pos;

void vertex() {
	vertex_pos = VERTEX;
}

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment()
{
	float basic_fresnel = fresnel(3.0, NORMAL, VIEW);
	ALBEDO = albedo.xyz + basic_fresnel;
	ALPHA = albedo.w + basic_fresnel;
	ALPHA = clamp((-vertex_pos.z - fade_offset) * fade_sharpness, 0.00, ALPHA);
}

