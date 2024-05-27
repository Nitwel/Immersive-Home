shader_type spatial;
render_mode blend_add,depth_draw_always, cull_disabled, diffuse_burley, specular_schlick_ggx, unshaded;

uniform vec3 border_color: source_color = vec3(0.0);
uniform bool show_border = false;

varying vec2 aspect_ratio;

void vertex() {
	aspect_ratio = CUSTOM0.rg;
}

void fragment() {
	ALBEDO = border_color;
	ALPHA = 0.0;
	
	vec2 pos = vec2(UV.x * aspect_ratio.x, UV.y * aspect_ratio.y);
	float border = 0.05;
	
	if( show_border ) {
		if (pos.x <= border) {
			ALPHA = mix(ALPHA, 1.0, 1.0 - pos.x / border);
		}
		 
		if (pos.x >= aspect_ratio.x - border) {
			ALPHA = mix(ALPHA, 1.0, (pos.x - (aspect_ratio.x - border)) / border);
		}
		
		if (pos.y <= border) {
			ALPHA = mix(ALPHA, 1.0, 1.0 - pos.y / border);
		}
		 
		if (pos.y >= aspect_ratio.y - border) {
			ALPHA = mix(ALPHA, 1.0, (pos.y - (aspect_ratio.y - border)) / border);
		}
	}
}
