shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_lambert, specular_schlick_ggx, unshaded;

uniform vec4 data[100];
uniform int data_size: hint_range(0, 100, 1);
uniform float alpha: hint_range(0.0, 1.0, 0.1) = 0.3;
uniform sampler2D color_gradient;

varying vec3 color;

float simple_weight(int index, vec3 world_pos, float p) {
	return 1.0 / pow(distance(data[index].xyz, world_pos), p);
}

float sphere_weight(int index, vec3 world_pos, float r) {
	float dist = distance(data[index].xyz, world_pos);
	return pow(max(0, r - dist) / (r * dist), 2);
}

void vertex() {
	// Calculate Global Coordinates
	vec3 world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	color = vec3(1.0, 1.0, 1.0);
	float distances[100];
	float dist_sum = 0.0;
	float data_sum = 0.0;
	
	float closest_dist = -1.0;
	int closest_index = 0;
	
	if(data_size > 0) {
		closest_dist = distance(data[0].xyz, world_position);
		
		// Inverse distance weighting using Shepard's method
		for(int i = 0; i < data_size; i++) {
			distances[i] = sphere_weight(i, world_position, 5.0);
			dist_sum += distances[i];
			data_sum += distances[i] * data[i].w;
			
			float dist = distance(data[i].xyz, world_position);
			
			if(dist < closest_dist) {
				closest_dist = dist;
				closest_index = i;
			}
		}
		
		float value = (1.0 / dist_sum) * data_sum;
		
		if( value > 0.0 || value < 1.0) {
			color.xyz = texture(color_gradient, vec2(value, 0)).xyz;
		} else {
			color.xyz = texture(color_gradient, vec2(data[closest_index].w, 0)).xyz;
		}
	}
}

void fragment() {
	ALBEDO = vec3(color.xyz);
	ALPHA = 0.3;
}
