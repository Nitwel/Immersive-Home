shader_type spatial;
render_mode blend_sub, depth_draw_always, cull_disabled, diffuse_burley, specular_schlick_ggx, unshaded;

void fragment() {
	ALBEDO = vec3(1.0);
}
