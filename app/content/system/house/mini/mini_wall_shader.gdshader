shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_lambert, specular_schlick_ggx, unshaded;

uniform vec4 data[100];
uniform int data_size: hint_range(0, 100, 1);
uniform vec2 min_max_data;
uniform sampler2D color_gradient;

varying vec3 color;



void vertex() {
	// Calculate Global Coordinates
	vec3 world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	color = vec3(1.0, 1.0, 1.0);
	vec2 distances[100];
	float dist_sum = 0.0;
	
	if(data_size > 0) {
		for(int i = 0; i < data_size; i++) {
			float delta = 1.0 / distance(data[i].xyz, world_position);
			
			distances[i] = vec2(delta, data[i].w);
			dist_sum += delta;
		}
		
		for(int i = 0; i < data_size; i++) {
			float average = distances[i].x / dist_sum * distances[i].y;
			color.xyz = texture(color_gradient, vec2(average, 0)).xyz;
		}
	}
}

void fragment() {
	ALBEDO = vec3(color.xyz);
	ALPHA = 0.3;
}
