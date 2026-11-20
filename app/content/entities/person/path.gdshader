shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;

// History paths (path_overlay.gd): lines and round dots in vertex colours, whose
// alpha fades out the older they are. Clipped to the map, since the mesh covers
// the whole path even where it leaves the visible area.

uniform vec2 bounds = vec2(1.0); // half size of the map in local units
uniform bool ground_plane = false; // 3D map: the map lies in XZ instead of XY
uniform bool circular = false; // round map: a circle of radius bounds.x
uniform float opacity = 1.0;
// Mesh -> map space, for a mesh that is moved / scaled over the map (building outlines)
uniform mat4 map_from_model = mat4(1.0);

varying vec3 local_position;

void vertex() {
	local_position = (map_from_model * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = ground_plane ? local_position.xz : local_position.xy;
	if (circular ? length(p) > bounds.x : (abs(p.x) > bounds.x || abs(p.y) > bounds.y)) {
		discard;
	}
	// Dots carry UVs 0..1; line quads carry -1 and are never cut.
	if (UV.x >= 0.0 && distance(UV, vec2(0.5)) > 0.5) {
		discard;
	}
	ALBEDO = COLOR.rgb;
	ALPHA = COLOR.a * opacity;
}
