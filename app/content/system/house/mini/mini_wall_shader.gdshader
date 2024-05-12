shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx, shadows_disabled;

uniform vec4 data[100];
uniform int data_size: hint_range(0, 100, 1);
uniform float alpha: hint_range(0.0, 1.0, 0.1) = 0.3;
uniform sampler2D color_gradient;

uniform float roughness : hint_range(0.0, 1.0) = 0.15;
uniform vec4 edge_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

varying vec3 color;

float simple_weight(int index, vec3 world_pos, float p) {
	return 1.0 / pow(distance(data[index].xyz, world_pos), p);
}

float sphere_weight(int index, vec3 world_pos, float r) {
	float dist = distance(data[index].xyz, world_pos);
	return pow(max(0, r - dist) / (r * dist), 2);
}

float SchlickFresnel(float u) {
	float m = 1.0 - u;
	float m2 = m * m;
	return m2 * m2 * m;
}

void vertex() {
	color = vec3(0.9, 0.9, 0.9);
	
	if(data_size > 0) {
		float distances[100];
		float dist_sum = 0.0;
		float data_sum = 0.0;
		
		float closest_dist = -1.0;
		int closest_index = 0;
		
		// Calculate Global Coordinates
		//vec3 world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
		
		closest_dist = distance(data[0].xyz, VERTEX);
		
		// Inverse distance weighting using Shepard's method
		for(int i = 0; i < data_size; i++) {
			distances[i] = sphere_weight(i, VERTEX, 5.0);
			dist_sum += distances[i];
			data_sum += distances[i] * data[i].w;
			
			float dist = distance(data[i].xyz, VERTEX);
			
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
	//ALPHA = alpha;
	
	float VdotN = dot(VIEW, NORMAL);
	float fresnel = clamp(SchlickFresnel(VdotN), 0.0, 1.0);
	
	// apply glass look
	//float a = mix(0.001, 1.0, ALPHA);
	//ALPHA = mix(fresnel * edge_color.a, 1.0, a);
	//ALBEDO = mix(edge_color.rgb * edge_color.a, ALBEDO, a);
	ROUGHNESS = roughness;
	//SPECULAR = 0.5 * inversesqrt(ALPHA);
	DEPTH = FRAGCOORD.z - 0.00001;
}