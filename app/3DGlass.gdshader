shader_type spatial;

uniform vec4 albedo: source_color = vec4(1.0, 1.0, 1.0, 0.4);


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

}
