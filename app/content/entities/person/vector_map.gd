extends SubViewport
## Draws the base map from OpenFreeMap vector tiles in the colours of Home
## Assistant's map card: cream land, light blue water, pale green parks, yellow main
## roads, white side streets and grey upper case district names with a white halo.
##
## Used as the texture of the flat map and of the 3D map's terrain. The geometry is
## prepared on a worker thread (vector_map_builder.gd); this node only draws the
## finished triangle lists and places the labels, so loading a map doesn't stall
## the headset. Street names along roads aren't drawn yet.

const Tiles = preload ("./map_tiles.gd")
const Builder = preload ("./vector_map_builder.gd")
const UiFont = preload ("res://assets/fonts/ui_font_500.tres")

## Texture pixels per map pixel, for crisp lines and text.
const SCALE = 2

const BACKGROUND = Color8(246, 242, 236)
const AREA_COLORS = {
	"residential": Color8(243, 238, 230),
	"commercial": Color8(244, 230, 227),
	"institution": Color8(240, 232, 222),
	"farmland": Color8(241, 239, 222),
	"sand": Color8(245, 236, 205),
	"rock": Color8(232, 228, 222),
	"ice": Color8(250, 252, 255),
	"green": Color8(214, 234, 198),
	"wood": Color8(198, 226, 183),
	"water": Color8(170, 211, 242),
	"building": Color8(232, 224, 214),
}
## Drawn in this order, so later areas cover earlier ones.
const AREA_ORDER = ["residential", "commercial", "institution", "farmland", "sand", "rock", "ice", "green", "wood", "water", "building"]
const BUILDINGS_MIN_ZOOM = 15

## style: [fill, casing (or null), width in map pixels at zoom 14, minimum zoom]
const LINE_STYLES = {
	"stream": [Color8(170, 211, 242), null, 1.0, 13],
	"river": [Color8(170, 211, 242), null, 2.5, 8],
	"rail": [Color8(188, 188, 188), null, 1.2, 10],
	"path": [Color8(214, 200, 180), null, 0.8, 15],
	"service": [Color.WHITE, Color8(224, 218, 208), 1.4, 15],
	"minor": [Color.WHITE, Color8(220, 213, 202), 2.4, 13],
	"secondary": [Color8(253, 238, 178), Color8(228, 205, 140), 3.0, 10],
	"primary": [Color8(252, 226, 140), Color8(225, 192, 105), 3.4, 8],
	"motorway": [Color8(249, 206, 104), Color8(215, 166, 70), 4.0, 5],
}
const LINE_ORDER = ["stream", "river", "rail", "path", "service", "minor", "secondary", "primary", "motorway"]

## style: [font size in map pixels, colour, upper case]
const LABEL_STYLES = {
	"city": [20, Color8(50, 50, 50), false],
	"town": [18, Color8(60, 60, 60), false],
	"district": [14, Color8(95, 95, 95), true],
	"village": [14, Color8(85, 85, 85), false],
	"water": [14, Color8(80, 125, 165), false],
}
const LABEL_ORDER = ["city", "town", "district", "village", "water"]
const HALO = Color(1, 1, 1, 0.9)

## At most this many labels per map, to keep the main thread's share small.
const MAX_LABELS = 30

## Emitted when a new drawing is shown.
signal drawn()

## View the shown drawing was made for: world pixel of its top left corner ([x, y]
## doubles, see Tiles.project_d), and zoom.
var drawn_top_left := [0.0, 0.0]
var drawn_zoom := 0
## Texture pixels per map pixel of the shown drawing
var _drawn_scale: float = SCALE

var _canvas := Node2D.new()
var _district_font: FontVariation
## Latest finished drawing from the builder: {layers, labels}.
var _drawing := {}
var _job_id := 0
var _building := false
var _next_job = null

func _init():
	disable_3d = true
	transparent_bg = false
	# No 2D MSAA in the Compatibility renderer; the 2x resolution smooths the edges.
	render_target_update_mode = SubViewport.UPDATE_ONCE
	canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR

	_district_font = FontVariation.new()
	_district_font.base_font = UiFont
	_district_font.spacing_glyph = 1

	add_child(_canvas)
	_canvas.draw.connect(_draw_map)

## Draws the map around [param center] (latitude, longitude) for a map of
## [param px_size] map pixels. Missing tiles are requested from [param loader];
## call again when it reports them loaded. The drawing is prepared on a worker
## thread and shown when ready.
##
## With a [param magnification] (fractional zoom: the map shown larger or smaller
## than its tile level), the texture keeps the resolution of the unmagnified map,
## so it stays sharp and labels keep their size.
func render(loader, center, zoom: int, px_size: Vector2, magnification := 1.0):
	size = Vector2i((px_size * SCALE * magnification).round())
	var tile_zoom = mini(zoom, Tiles.VECTOR_MAX_ZOOM)
	_job_id += 1
	var job = {
		"id": _job_id,
		"tiles": loader.tiles_around("vector", center, zoom, px_size, tile_zoom).tiles,
		"zoom": zoom,
		"zoom_f": zoom + log(magnification) / log(2.0),
		"tile_zoom": tile_zoom,
		"top_left": _top_left(center, zoom, px_size),
		"texture_size": Vector2(size),
		"scale": SCALE * magnification,
		"pixel_scale": SCALE,
		"background": BACKGROUND,
		"area_order": AREA_ORDER,
		"area_colors": AREA_COLORS,
		"buildings_min_zoom": BUILDINGS_MIN_ZOOM,
		"line_order": LINE_ORDER,
		"line_styles": LINE_STYLES,
		"label_order": LABEL_ORDER,
	}
	if _building:
		_next_job = job # only the newest waiting job matters
		return
	_start(job)

## [x, y] world pixels (doubles) of the top left corner of a map around [param center].
static func _top_left(center, zoom: int, px_size: Vector2) -> Array:
	var c = Tiles.project_d(center[0], center[1], zoom)
	return [c[0] - px_size.x / 2.0, c[1] - px_size.y / 2.0]

func _start(job: Dictionary):
	_building = true
	WorkerThreadPool.add_task(Builder.task.bind(weakref(self), job))

## Back on the main thread with a finished drawing.
func _on_built(result: Dictionary):
	_building = false
	if _next_job != null:
		var job = _next_job
		_next_job = null
		_start(job)
	# Jobs run one after another, so this is newer than what is shown, even if a newer
	# view is already on its way. Showing it keeps a map that is being dragged moving;
	# drawn_top_left / drawn_zoom let the map line it up with the current view.
	_drawing = result
	drawn_top_left = result.top_left
	drawn_zoom = result.zoom
	_drawn_scale = result.scale
	_canvas.queue_redraw()
	render_target_update_mode = SubViewport.UPDATE_ONCE
	drawn.emit()

## Where the shown drawing sits in a view with [param top_left] ([x, y] world pixels
## at [param zoom]): Vector3(offset.x, offset.y, scale), so that a view pixel p is at
## p * scale + offset in the drawing's pixels.
func drawn_mapping(top_left: Array, zoom: int) -> Vector3:
	if _drawing.is_empty():
		return Vector3(0, 0, 1)
	var scale = pow(2.0, drawn_zoom - zoom)
	# Doubles until the difference: the world pixel values are huge.
	var offset = Vector2(top_left[0] * scale - drawn_top_left[0], top_left[1] * scale - drawn_top_left[1])
	return Vector3(offset.x, offset.y, scale)

## Sets [param material]'s texture mapping uniforms (see map.gdshader) for a view.
func apply_mapping(material: ShaderMaterial, top_left: Array, zoom: int):
	var mapping = drawn_mapping(top_left, zoom)
	material.set_shader_parameter("texture_offset", Vector2(mapping.x, mapping.y))
	material.set_shader_parameter("texture_scale", mapping.z)
	# The drawing is in texture pixels (_drawn_scale per map pixel) of the viewport,
	# whatever size that has now.
	material.set_shader_parameter("texture_size_px", Vector2(size) / _drawn_scale)

func _draw_map():
	_canvas.draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND)
	if _drawing.is_empty():
		return
	var item = _canvas.get_canvas_item()
	for layer in _drawing.layers:
		RenderingServer.canvas_item_add_triangle_array(item, layer[1], layer[0], PackedColorArray([layer[2]]))
	_draw_labels()

## Labels arrive sorted and on the map; placing them needs the font, so it stays here.
func _draw_labels():
	var placed: Array[Rect2] = []
	var bounds = Rect2(Vector2.ZERO, size).grow(-4)
	for label in _drawing.labels:
		if placed.size() >= MAX_LABELS:
			break
		var style = LABEL_STYLES[label[0]]
		var font: Font = _district_font if style[2] else UiFont
		var text = label[1].to_upper() if style[2] else label[1]
		var font_size = style[0] * SCALE
		var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var rect = Rect2(label[2] - text_size / 2.0, text_size).grow(2 * SCALE)
		if not bounds.encloses(rect) or placed.any(func(other): return other.intersects(rect)):
			continue # off the map, or overlapping a more important label (also drops duplicates)
		placed.append(rect)
		var baseline = Vector2(label[2].x - text_size.x / 2.0, label[2].y + font.get_ascent(font_size) - text_size.y / 2.0)
		_canvas.draw_string_outline(font, baseline, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 3 * SCALE, HALO)
		_canvas.draw_string(font, baseline, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, style[1])