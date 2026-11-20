shader_type spatial;
// Writes depth itself: the transparent pass has no reliable depth prepass on every
// renderer, and the terrain must still hide its own base while fading.
render_mode unshaded, cull_disabled, depth_draw_always;

#define FADE
#include "res://content/entities/person/diorama.gdshaderinc"
