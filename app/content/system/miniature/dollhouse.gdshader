shader_type spatial;
render_mode unshaded, cull_disabled;

// Floors and walls of the dollhouse (dollhouse.gd): the rooms on the Map View.
//
// Unshaded with a fixed light in model space, like the 3D map, so walls facing
// different ways read apart however the room is lit (the app mostly runs on
// passthrough). Faces carry UVs 0..1 (UV2.x = 1 marks faces that get them), and
// their edges are drawn as lines of constant screen width, anti-aliased, so the
// walls stay crisp at every zoom.

uniform vec3 light_direction = vec3(0.35, 1.0, 0.55); // model space, towards the light
uniform float ambient = 0.55;
uniform vec3 edge_color : source_color = vec3(0.32, 0.33, 0.36);
uniform float edge_pixels = 1.2;

// Heat map on the floors (UV2.y = 1 marks them): sensor readings (xyz: position in
// the house, w: value 0..1) blended by inverse squared distance over all sensors, so
// it shades smoothly between rooms, coloured by color_gradient.
uniform bool heat = false;
uniform vec4 data[100];
uniform int data_size = 0;
// sRGB colours, so they come out as picked (the same as the Home Assistant cards)
uniform sampler2D color_gradient : source_color;
uniform float heat_strength = 0.85;

// Lights that are on (dollhouse_entities.gd): a soft wash of their colour on the floors
// and walls around them, fading out over light_radius (m, in the floor plan). Only the
// rooms get it, not the map around the house.
uniform vec4 light_positions[32]; // xyz: in the house
uniform vec4 light_colors[32]; // rgb, a: brightness 0..1
uniform int light_count = 0;
uniform float light_radius = 2.5;
uniform float light_strength = 0.3;

varying vec3 model_position;

void vertex() {
	model_position = VERTEX;
}

vec3 heat_color(vec3 position) {
	float weight_sum = 0.0;
	float value_sum = 0.0;
	for (int i = 0; i < data_size; i++) {
		// Measured in the floor plan: the sensors' heights don't matter here
		float dist = max(distance(data[i].xz, position.xz), 0.2);
		float weight = 1.0 / (dist * dist);
		weight_sum += weight;
		value_sum += weight * data[i].w;
	}
	return texture(color_gradient, vec2(clamp(value_sum / weight_sum, 0.0, 1.0), 0.0)).rgb;
}

// Cut off at the round map's rim, as in mini_wall_shader.gdshader
uniform bool clip_to_disc = false;
uniform vec3 disc_center = vec3(0.0);
uniform vec3 disc_normal = vec3(0.0, 1.0, 0.0);
uniform float disc_radius = 1.0;

void fragment() {
	if (clip_to_disc) {
		vec3 offset = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz - disc_center;
		if (length(offset - dot(offset, disc_normal) * disc_normal) > disc_radius) {
			discard;
		}
	}

	vec3 normal = normalize(NORMAL);
	if (dot(normal, -VERTEX) < 0.0) {
		normal = -normal; // seen from behind (cull_disabled)
	}
	vec3 light = normalize((VIEW_MATRIX * MODEL_MATRIX * vec4(light_direction, 0.0)).xyz);
	vec3 base = COLOR.rgb;
	if (heat && data_size > 0 && UV2.y > 0.5) {
		base = mix(base, heat_color(model_position), heat_strength);
	}
	vec3 color = base * (ambient + (1.0 - ambient) * max(dot(normal, light), 0.0));

	vec3 wash = vec3(0.0);
	for (int i = 0; i < light_count; i++) {
		float reach = clamp(1.0 - distance(light_positions[i].xz, model_position.xz) / light_radius, 0.0, 1.0);
		wash += light_colors[i].rgb * light_colors[i].a * reach * reach;
	}
	// Light on the surface: tinted by what it falls on, so dark caps barely catch it
	color += base * wash * light_strength;

	if (UV2.x > 0.5) {
		// Distance to the face's nearest edge, in pixels
		vec2 to_edge = min(UV, 1.0 - UV) / max(fwidth(UV), vec2(1e-6));
		float line = 1.0 - smoothstep(edge_pixels - 0.5, edge_pixels + 0.5, min(to_edge.x, to_edge.y));
		color = mix(color, edge_color, line * 0.85);
	}
	ALBEDO = color;
}
