shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;

// Soft shadow on the floor along the walls (dollhouse.gd): vertex colours, whose
// alpha fades from the wall into the room. Cut off at the map's rim like the rest.

uniform bool clip_to_disc = false;
uniform vec3 disc_center = vec3(0.0);
uniform vec3 disc_normal = vec3(0.0, 1.0, 0.0);
uniform float disc_radius = 1.0;
uniform float opacity = 1.0;

void fragment() {
	if (clip_to_disc) {
		vec3 offset = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz - disc_center;
		if (length(offset - dot(offset, disc_normal) * disc_normal) > disc_radius) {
			discard;
		}
	}
	ALBEDO = COLOR.rgb;
	ALPHA = COLOR.a * opacity;
}
