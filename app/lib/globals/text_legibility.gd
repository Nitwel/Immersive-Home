extends Node
## Makes Label3D text bolder as it gets smaller on screen, so it stays legible
## at a distance instead of fading into a gray blur.
##
## Thin strokes narrower than a pixel get blended with the background. A
## same-colored outline thickens every stroke; with MSDF fonts it is computed
## from the glyph's distance field, so it is cheap (one extra pass on the same
## atlas) and doesn't change the text layout.
##
## Only labels that have no outline of their own (outline_size == 0) and use an
## MSDF font are managed.

## Apparent em size (font_size * pixel_size / distance, in radians) at and above
## which text gets no extra weight. 0.015 = an 18mm em seen from 1.2m.
const FULL_SIZE_ANGLE = 0.015
## Outline added per unit of (FULL_SIZE_ANGLE / angle - 1), as a fraction of the em.
## Tuned so an 18mm em at 3m gets an outline of ~3 font pixels (0.17 em).
const WEIGHT_PER_STEP = 0.11
## Upper bound as a fraction of the em. MSDF fonts can only draw outlines up to
## msdf_pixel_range / (2 * msdf_size) before artifacts (0.21 for Montserrat,
## 0.18 for the icons); the per-font limit is this fraction of that.
const MAX_WEIGHT_OF_MSDF_RANGE = 0.95

## Icon glyphs fill their em with much thinner strokes than letters, so they
## are treated as if their em were this much smaller.
const ICON_FONT = preload("res://assets/icons/icons.tres")
const ICON_SIZE_FACTOR = 0.5

const META_SETTINGS = "_text_legibility"

## Label3D -> true. Labels leave the set when freed or taken out of the tree;
## node_added puts them back if they re-enter.
var _labels := {}

func _ready():
	get_tree().node_added.connect(_on_node_added)
	for node in get_tree().root.find_children("*", "Label3D", true, false):
		_on_node_added(node)
	EventSystem.on_slow_tick.connect(_update)

func _on_node_added(node: Node):
	if node is Label3D:
		_labels[node] = true

func _update(_delta: float):
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return
	var eye = camera.global_position

	for label in _labels.keys():
		if not is_instance_valid(label) or not label.is_inside_tree():
			_labels.erase(label)
			continue

		if not label.is_visible_in_tree():
			continue
		var settings = _settings(label)
		if not settings.managed:
			continue

		var em = label.font_size * label.pixel_size * label.global_basis.get_scale().y * settings.size_factor
		var distance = max(eye.distance_to(label.global_position), 0.01)
		var angle = em / distance

		var weight = clampf((FULL_SIZE_ANGLE / angle - 1.0) * WEIGHT_PER_STEP, 0.0, settings.max_weight)
		var outline = roundi(weight * label.font_size)

		if label.outline_size != outline:
			label.outline_size = outline
		if outline > 0 and label.outline_modulate != label.modulate:
			label.outline_modulate = label.modulate

## Per-label settings, recomputed when the label's font changes (e.g. a button
## switching to its icon font). Only labels without their own outline, in an
## MSDF font, are managed.
func _settings(label: Label3D) -> Dictionary:
	# get_meta() treats a null default as "no default" and errors, so check first.
	var settings = label.get_meta(META_SETTINGS) if label.has_meta(META_SETTINGS) else null
	if settings != null and settings.font == label.font:
		return settings

	var managed_before = settings != null and settings.managed
	var font = _label_font(label)
	var msdf = _msdf_font(font)
	settings = {
		"font": label.font,
		# outline_size > 0 here is our own outline if we managed this label before
		"managed": msdf != null and (label.outline_size == 0 or managed_before),
		"size_factor": ICON_SIZE_FACTOR if font == ICON_FONT else 1.0,
		"max_weight": 0.0,
	}
	if settings.managed:
		settings.max_weight = MAX_WEIGHT_OF_MSDF_RANGE * msdf.msdf_pixel_range / (2.0 * msdf.msdf_size)
		if label.outline_render_priority >= label.render_priority:
			label.outline_render_priority = label.render_priority - 1
	label.set_meta(META_SETTINGS, settings)
	return settings

## Same lookup as Label3D: own font, else the project theme / custom font, else the engine fallback.
func _label_font(label: Label3D) -> Font:
	if label.font != null:
		return label.font
	for theme in [ThemeDB.get_project_theme(), ThemeDB.get_default_theme()]:
		if theme != null and theme.default_font != null:
			return theme.default_font
	return ThemeDB.fallback_font

## The underlying FontFile if it renders as MSDF, else null.
func _msdf_font(font: Font) -> FontFile:
	while font is FontVariation:
		font = font.base_font
	if font is FontFile and font.multichannel_signed_distance_field:
		return font
	return null
