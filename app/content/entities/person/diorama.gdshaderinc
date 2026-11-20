// Shared by diorama.gdshader (opaque) and diorama_fade.gdshader (fading out, see
// Tiles.map_opacity): only the fading one is a transparent object, so the map draws
// like before (with depth) whenever it is fully shown.
// Shared by the 3D map's terrain, buildings, trees and pins.
//
// Unshaded with a fixed light in model space, so the diorama reads as 3D without
// depending on the scene's lights (the app mostly runs on passthrough). Normals
// come from screen-space derivatives: flat, low-poly shading with no need for
// correct normals or winding on the generated meshes.

uniform vec4 base_color : source_color = vec4(0.8, 0.8, 0.8, 1.0);
uniform bool use_vertex_color = false;
uniform bool use_texture = false;
uniform sampler2D map_texture : source_color, filter_linear;
uniform bool dark_mode = false; // the vector map is drawn in Home Assistant's light colours
uniform vec3 light_direction = vec3(0.35, 1.0, 0.55); // model space, towards the light
uniform float ambient = 0.5;
uniform float opacity = 1.0;

// Terrain texture mapping, as in map.gdshader: the drawing can be for a different
// view than the terrain was built for.
uniform vec2 texture_offset = vec2(0.0);
uniform float texture_scale = 1.0;
uniform vec2 texture_size_px = vec2(448.0, 320.0);
uniform vec3 background : source_color = vec3(0.965, 0.949, 0.925);

// While the map is dragged, the built terrain, buildings and trees are moved along
// until the next build arrives; whatever leaves the diorama's footprint is cut off.
// ground_from_world: world -> ground space (x east, z south, centred on the map).
uniform bool clip = false;
uniform mat4 ground_from_world = mat4(1.0);
uniform vec2 half_size = vec2(0.14, 0.1);
uniform bool circular = false; // round map: a circle of radius half_size.x

// Zone / accuracy circles on the terrain texture, as in map.gdshader
uniform vec2 size_px = vec2(448.0, 320.0);
uniform vec4 circles[8];
uniform vec4 circle_colors[8];
uniform int circle_count = 0;

// Buildings whose centre lies within ghost_radius of ghost_center are drawn as an
// outline only, so the miniature house standing there (Map View) can be seen.
// Model space of the buildings mesh; needs its CUSTOM0 / UV2 (map_3d_builder.gd).
uniform bool ghost = false;
uniform vec2 ghost_center = vec2(0.0);
uniform float ghost_radius = 0.0;
uniform float ghost_line = 0.0005;
uniform vec3 ghost_color : source_color = vec3(1.0);

varying vec3 model_vertex;
varying vec4 building;
varying vec2 building_height;

void vertex() {
	model_vertex = VERTEX;
	building = CUSTOM0;
	building_height = UV2;
}

vec3 darken_map(vec3 color) {
	// Invert brightness, keep hue (YIQ), as in map.gdshader
	mat3 to_yiq = mat3(vec3(0.299, 0.596, 0.211), vec3(0.587, -0.274, -0.523), vec3(0.114, -0.322, 0.312));
	mat3 to_rgb = mat3(vec3(1.0, 1.0, 1.0), vec3(0.956, -0.272, -1.106), vec3(0.621, -0.647, 1.703));
	vec3 yiq = to_yiq * color;
	yiq.x = mix(0.06, 0.8, 1.0 - yiq.x);
	yiq.yz *= 0.6;
	return clamp(to_rgb * yiq, 0.0, 1.0);
}

void fragment() {
	if (clip) {
		vec3 world = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
		vec3 ground = (ground_from_world * vec4(world, 1.0)).xyz;
		if (circular ? length(ground.xz) > half_size.x : (abs(ground.x) > half_size.x || abs(ground.z) > half_size.y)) {
			discard;
		}
	}

	vec3 color = base_color.rgb;
	if (use_vertex_color) {
		color = COLOR.rgb;
	}
	bool outline = false;
	if (ghost && distance(building.xy, ghost_center) < ghost_radius) {
		// Roofs go; walls keep a frame along their corners, bottom and top.
		float along = building.z;
		float wall_length = building.w;
		float height = model_vertex.y;
		bool edge = along < ghost_line || along > wall_length - ghost_line
			|| height < building_height.x + ghost_line || height > building_height.y - ghost_line;
		if (wall_length < 0.0 || !edge) {
			discard;
		}
		outline = true;
	}
	if (use_texture) {
		vec2 p = UV * size_px;
		vec2 uv = (p * texture_scale + texture_offset) / texture_size_px;
		color = background;
		if (uv.x >= 0.0 && uv.y >= 0.0 && uv.x <= 1.0 && uv.y <= 1.0) {
			color = texture(map_texture, uv).rgb;
		}
		if (dark_mode) {
			color = darken_map(color);
		}
		for (int i = 0; i < circle_count; i++) {
			float d = distance(p, circles[i].xy);
			float r = circles[i].z;
			if (d < r) {
				color = mix(color, circle_colors[i].rgb, circle_colors[i].a);
			}
			float edge = 1.0 - smoothstep(0.0, 1.5, abs(d - r));
			color = mix(color, circle_colors[i].rgb, edge * 0.85);
		}
	}

	// Flat face normal in view space, turned towards the camera.
	vec3 normal = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	if (dot(normal, -VERTEX) < 0.0) {
		normal = -normal;
	}
	vec3 light = normalize((VIEW_MATRIX * MODEL_MATRIX * vec4(light_direction, 0.0)).xyz);
	float lit = ambient + (1.0 - ambient) * max(dot(normal, light), 0.0);

	ALBEDO = outline ? ghost_color : color * lit;
#ifdef FADE
	ALPHA = opacity;
#endif
}
