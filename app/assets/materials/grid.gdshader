shader_type spatial;

render_mode unshaded, cull_back;

uniform float dot_size: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float dot_falloff: hint_range(0.0, 0.4, 0.001) = 0.1;
uniform float size: hint_range(1.0, 32.0, 0.1) = 16.0;
uniform vec2 dot_offset = vec2(0.0);
uniform int supersampling: hint_range(0, 10, 1) = 1;

vec2 random(vec2 st){
    return vec2(fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123), fract(sin(dot(st.xy, vec2(-40.644))) * 87502.29935));
}

float sdf_sphere(vec2 position, float center_dist) {
	return length(position) - max(0.0, dot_size / size - center_dist * dot_falloff);
}

vec2 sdf_repeat(vec2 position) {
	float inv_size = 1.0 / (size * 2.0);
	return fract(position * size) / size - inv_size;
}

void fragment() {
	float total_dist = 0.0;

	for(int i = 0; i < supersampling; i++) {
		float center_dist = distance(UV, vec2(0.5, 0.5));
		vec2 rand = random(vec2(float(i))) * 0.004 * (0.5 - center_dist);
		float dist = sdf_sphere(sdf_repeat(UV - dot_offset - rand), center_dist);
		if (dist <= 0.0) {
			total_dist += 1.0 / float(supersampling);
		}
	}

	ALBEDO = vec3(1.0);
	ALPHA = total_dist;

	//if(dist <= 0.0) {
		//ALBEDO = vec3(1.0);
	//} else {
		//ALBEDO = vec3(1.0);
		//ALPHA = dist;
	//}
}

