shader_type spatial;

render_mode cull_disabled, unshaded;

uniform vec2 steps = vec2(10.0,10.0);
uniform vec2 size= vec2(0.002, 0.002);
uniform vec2 offset = vec2(0.001, 0.001);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = vec3(0.5, 0.5, 0.5);
	vec2 parts = 1.0 / steps;
	
	float y_mod = mod(UV.y + offset.y, parts.y);
	float x_mod = mod(UV.x + offset.x, parts.x);
	
	if (x_mod < size.x / 2.0 || x_mod > parts.x - size.x / 2.0 || y_mod < size.y || y_mod > parts.y - size.y / 2.0) {
		
		ALPHA = 0.7;
	} else {
		ALPHA = 0.3;
	}
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
