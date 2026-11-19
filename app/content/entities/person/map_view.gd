extends Node3D
## A flat slippy map: builds one texture from the map tiles around [member center]
## and places markers and circles (zones, GPS accuracy) at map coordinates.
##
## Set [member size], [member center], [member zoom], [member markers] and
## [member circles], then call [method refresh]. Missing tiles are downloaded and
## the map is redrawn as they arrive.

const Tiles = preload ("./map_tiles.gd")
const MapShader = preload ("./map.gdshader")
const MarkerShader = preload ("./marker.gdshader")
const IconFont = preload ("res://assets/icons/icons.tres")

## Map pixels per meter of panel.
const PIXELS_PER_METER = 1600.0
## Shown where tiles are still loading; light because the shader darkens the map.
const BACKGROUND = Color(0.9, 0.9, 0.88)

## Size of the map in meters.
var size := Vector2(0.28, 0.19)
## Map centre as Vector2(latitude, longitude).
var center := Vector2.ZERO
var zoom := 15
## Each: {lat, lon, color: Color, texture: Texture2D or null, text: String, icon: bool, diameter: float (m)}
var markers: Array = []
## Each: {lat, lon, radius: float (meters), color: Color (alpha = fill opacity)}
var circles: Array = []

var _quad: MeshInstance3D
var _material: ShaderMaterial
var _texture: ImageTexture
var _attribution: Label3D
var _marker_nodes: Array = []
var _downloads := {} ## tile key -> HTTPRequest
var _queue: Array = [] ## [z, x, y] waiting for a free download slot
var _failed := {}
var _compose_queued = false

func _ready():
	_material = ShaderMaterial.new()
	_material.shader = MapShader
	_material.render_priority = 12

	_quad = MeshInstance3D.new()
	_quad.mesh = QuadMesh.new()
	_quad.material_override = _material
	add_child(_quad)

	_attribution = Label3D.new()
	_attribution.text = Tiles.ATTRIBUTION
	_attribution.font_size = 7
	_attribution.pixel_size = 0.001
	_attribution.outline_size = 0
	_attribution.render_priority = 15
	_attribution.modulate = Color(1, 1, 1, 0.55)
	_attribution.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_attribution.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	add_child(_attribution)

func _px_size() -> Vector2:
	return (size * PIXELS_PER_METER).round()

func _top_left() -> Vector2:
	return Tiles.project(center.x, center.y, zoom) - _px_size() / 2.0

## Local position (meters, on the map plane) of a coordinate.
func to_local_position(latitude: float, longitude: float) -> Vector3:
	var p = (Tiles.project(latitude, longitude, zoom) - _top_left()) / PIXELS_PER_METER
	return Vector3(p.x - size.x / 2.0, size.y / 2.0 - p.y, 0)

## Largest zoom (up to [param max_zoom]) at which all coordinates fit, with a margin.
func fit_zoom(points: Array, max_zoom := 16) -> int:
	for z in range(max_zoom, Tiles.MIN_ZOOM - 1, -1):
		var lo = Vector2(INF, INF)
		var hi = Vector2(-INF, -INF)
		for point in points:
			var p = Tiles.project(point.x, point.y, z)
			lo = lo.min(p)
			hi = hi.max(p)
		if hi.x - lo.x <= _px_size().x * 0.7 and hi.y - lo.y <= _px_size().y * 0.7:
			return z
	return Tiles.MIN_ZOOM

func refresh():
	if not is_node_ready():
		return
	zoom = clampi(zoom, Tiles.MIN_ZOOM, Tiles.MAX_ZOOM)

	_quad.mesh.size = size
	_attribution.position = Vector3(size.x / 2.0 - 0.006, -size.y / 2.0 + 0.004, 0.001)
	_material.set_shader_parameter("size_px", _px_size())
	_material.set_shader_parameter("corner_radius_px", 0.008 * PIXELS_PER_METER)

	_update_circles()
	_update_markers()
	_compose()

# ---------------------------------------------------------------------------
# Tiles
# ---------------------------------------------------------------------------

func _visible_tiles() -> Array:
	var top_left = _top_left()
	var bottom_right = top_left + _px_size()
	var count = 1 << zoom
	var result = []
	for ty in range(floori(top_left.y / Tiles.TILE_SIZE), floori(bottom_right.y / Tiles.TILE_SIZE) + 1):
		if ty < 0 or ty >= count:
			continue
		for tx in range(floori(top_left.x / Tiles.TILE_SIZE), floori(bottom_right.x / Tiles.TILE_SIZE) + 1):
			result.append(Vector2i(tx, ty)) # tx may be outside 0..count-1; wrapped when fetched
	return result

func _compose():
	var px = _px_size()
	var image = Image.create(int(px.x), int(px.y), false, Image.FORMAT_RGBA8)
	image.fill(BACKGROUND)

	var top_left = _top_left()
	var count = 1 << zoom
	for tile in _visible_tiles():
		var x = posmod(tile.x, count)
		var tile_image = Tiles.get_cached(zoom, x, tile.y)
		if tile_image == null:
			_request(zoom, x, tile.y)
			continue
		var dst = Vector2i((Vector2(tile) * Tiles.TILE_SIZE - top_left).round())
		_blit_clipped(image, tile_image, dst)

	if _texture == null or _texture.get_size() != Vector2(image.get_size()):
		_texture = ImageTexture.create_from_image(image)
		_material.set_shader_parameter("map_texture", _texture)
	else:
		_texture.update(image)

static func _blit_clipped(target: Image, source: Image, dst: Vector2i):
	var src_rect = Rect2i(Vector2i.ZERO, source.get_size())
	var dst_rect = Rect2i(dst, source.get_size()).intersection(Rect2i(Vector2i.ZERO, target.get_size()))
	if dst_rect.size.x <= 0 or dst_rect.size.y <= 0:
		return
	src_rect.position = dst_rect.position - dst
	src_rect.size = dst_rect.size
	target.blit_rect(source, src_rect, dst_rect.position)

func _request(z: int, x: int, y: int):
	var k = Tiles.key(z, x, y)
	if _downloads.has(k) or _failed.has(k) or _queue.any(func(t): return Tiles.key(t[0], t[1], t[2]) == k):
		return
	_queue.append([z, x, y])
	_start_downloads()

func _start_downloads():
	while _downloads.size() < Tiles.MAX_PARALLEL_DOWNLOADS and not _queue.is_empty():
		var t = _queue.pop_front()
		# Skip tiles the user zoomed away from while they waited.
		if t[0] != zoom:
			continue
		_download(t[0], t[1], t[2])

func _download(z: int, x: int, y: int):
	var k = Tiles.key(z, x, y)
	var http = HTTPRequest.new()
	http.timeout = 15
	add_child(http)
	_downloads[k] = http
	http.request_completed.connect(func(result, code, _headers, body):
		_downloads.erase(k)
		http.queue_free()
		if result == HTTPRequest.RESULT_SUCCESS and code == 200 and Tiles.store(z, x, y, body) != null:
			_queue_compose()
		else:
			_failed[k] = true
			push_warning("Map tile %s failed: result %d, HTTP %d" % [k, result, code])
		_start_downloads()
	)
	if http.request(Tiles.url(z, x, y), [Tiles.USER_AGENT]) != OK:
		_downloads.erase(k)
		_failed[k] = true
		http.queue_free()

## Redraws once per frame at most, however many tiles arrive in it.
func _queue_compose():
	if _compose_queued:
		return
	_compose_queued = true
	(func():
		_compose_queued = false
		if is_inside_tree():
			_compose()
	).call_deferred()

# ---------------------------------------------------------------------------
# Overlays
# ---------------------------------------------------------------------------

func _update_circles():
	var top_left = _top_left()
	var centers = []
	var colors = []
	for circle in circles.slice(0, 8):
		var p = Tiles.project(circle.lat, circle.lon, zoom) - top_left
		var radius = circle.radius / Tiles.meters_per_pixel(circle.lat, zoom)
		centers.append(Vector4(p.x, p.y, radius, 0))
		var color: Color = circle.color
		colors.append(Vector4(color.r, color.g, color.b, color.a))
	while centers.size() < 8:
		centers.append(Vector4.ZERO)
		colors.append(Vector4.ZERO)
	_material.set_shader_parameter("circles", centers)
	_material.set_shader_parameter("circle_colors", colors)
	_material.set_shader_parameter("circle_count", min(circles.size(), 8))

func _update_markers():
	while _marker_nodes.size() < markers.size():
		_marker_nodes.append(_create_marker_node())

	for i in _marker_nodes.size():
		var node: Node3D = _marker_nodes[i]
		if i >= markers.size():
			node.visible = false
			continue

		var marker = markers[i]
		var diameter = marker.get("diameter", 0.028)
		var position_on_map = to_local_position(marker.lat, marker.lon)
		# Hide markers whose centre is off the map.
		node.visible = abs(position_on_map.x) <= size.x / 2.0 and abs(position_on_map.y) <= size.y / 2.0
		node.position = position_on_map + Vector3(0, 0, 0.002 + i * 0.0005)

		var disc: MeshInstance3D = node.get_node("Disc")
		disc.mesh.size = Vector2(diameter, diameter)
		var material: ShaderMaterial = disc.material_override
		var texture = marker.get("texture")
		material.set_shader_parameter("has_picture", texture != null)
		material.set_shader_parameter("picture", texture)
		material.set_shader_parameter("color", marker.get("color", Color(0.949, 0.353, 0.22)))

		var label: Label3D = node.get_node("Label")
		label.visible = texture == null
		label.text = marker.get("text", "")
		label.font = IconFont if marker.get("icon", false) else null
		label.font_size = int(diameter * 1000 * (0.75 if marker.get("icon", false) else 0.5))

func _create_marker_node() -> Node3D:
	var node = Node3D.new()

	var disc = MeshInstance3D.new()
	disc.name = "Disc"
	disc.mesh = QuadMesh.new()
	var material = ShaderMaterial.new()
	material.shader = MarkerShader
	material.render_priority = 13
	disc.material_override = material
	node.add_child(disc)

	var label = Label3D.new()
	label.name = "Label"
	label.pixel_size = 0.001
	label.outline_size = 0
	label.render_priority = 15
	label.position.z = 0.0005
	node.add_child(label)

	add_child(node)
	return node
