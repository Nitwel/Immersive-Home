shader_type spatial;
render_mode blend_mix, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 data[100];
uniform int data_size: hint_range(0, 100, 1);
uniform float alpha: hint_range(0.0, 1.0, 0.1) = 0.3;
uniform float border: hint_range(0.0, 1.0, 0.01) = 0.3;
uniform bool smooth_border = false;
uniform sampler2D color_gradient;

uniform float roughness : hint_range(0.0, 1.0) = 0.85;
uniform vec4 edge_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

varying vec3 color;
varying vec2 aspect_ratio;

float simple_weight(int index, vec3 world_pos, float p) {
	return 1.0 / pow(distance(data[index].xyz, world_pos), p);
}

float sphere_weight(int index, vec3 world_pos, float r) {
	float dist = distance(data[index].xyz, world_pos);
	return pow(max(0, r - dist) / (r * dist), 2);
}

void vertex() {
	color = vec3(0.7, 0.7, 0.7);
	aspect_ratio = CUSTOM0.rg;

	if(data_size > 0) {
		float distances[100];
		float dist_sum = 0.0;
		float data_sum = 0.0;

		float closest_dist = -1.0;
		int closest_index = 0;

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
	ROUGHNESS = roughness;
	DEPTH = FRAGCOORD.z + 0.0001;
	ALBEDO = vec3(color.xyz);

	vec2 pos = vec2(UV.x * aspect_ratio.x, UV.y * aspect_ratio.y);

	float blend = 0.0;

	if (pos.x <= border) {
		blend = max(blend, 1.0 - pos.x / border);
	}
	
	if (pos.x >= aspect_ratio.x - border) {
		blend = max(blend, (pos.x - (aspect_ratio.x - border)) / border);
	}

	if (pos.y <= border) {
		blend = max(blend, 1.0 - pos.y / border);
	}
	
	if (pos.y >= aspect_ratio.y - border) {
		blend = max(blend, (pos.y - (aspect_ratio.y - border)) / border);
	}
	
	if (smooth_border) {
		ALBEDO = mix(ALBEDO, mix(ALBEDO, edge_color.rgb, edge_color.a), blend * blend);
	} else if(blend > 0.0) {
		ALBEDO = mix(ALBEDO, edge_color.rgb, edge_color.a);
	}
}