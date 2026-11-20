extends Node3D
## A flat slippy map: builds one texture from the map tiles around [member center]
## and places markers and circles (zones, GPS accuracy) at map coordinates.
##
## Set [member size], [member center], [member zoom], [member markers] and
## [member circles], then call [method refresh]. Missing tiles are downloaded and
## the map is redrawn as they arrive.

const Tiles = preload ("./map_tiles.gd")
const TileLoader = preload ("./tile_loader.gd")
const VectorMap = preload ("./vector_map.gd")
const PathOverlay = preload ("./path_overlay.gd")
const BuildingOutlines = preload ("./building_outlines.gd")
const MapShader = preload ("./map.gdshader")
## Same, transparent: used only while the map fades out into the rooms
const MapFadeShader = preload ("./map_fade.gdshader")
const MarkerShader = preload ("./marker.gdshader")
const IconFont = preload ("res://assets/icons/icons.tres")

## Map pixels per meter of panel.
const PIXELS_PER_METER = 1600.0

## Size of the map in meters.
var size := Vector2(0.28, 0.19)
## Round map: a circle of diameter size.x (keep size square) instead of a rectangle.
var circular := false
## Map centre as [latitude, longitude] doubles. A Vector2 can be assigned too, but
## only resolves about half a meter: too coarse to drag a map smoothly up close.
var center = [0.0, 0.0]:
	set(value):
		center = [float(value[0]), float(value[1])]
var zoom := 15
## Highest fractional zoom; up to Tiles.ROOMS_MAX_ZOOM on a map that shows the
## miniature house, which takes over from the base map past Tiles.ROOMS_FROM_ZOOM.
var max_zoom := float(Tiles.MAX_ZOOM)
## Draw building footprints when zoomed in close (Map View, see building_outlines.gd).
var building_outlines := false
## How much larger the map is shown than its tile level, for fractional zoom
## (see [method set_fractional_zoom]).
var magnification := 1.0
## Each: {lat, lon, color: Color, texture: Texture2D or null, text: String, icon: bool, diameter: float (m)}
var markers: Array = []
## Each: {lat, lon, radius: float (meters), color: Color (alpha = fill opacity)}
var circles: Array = []
## History paths, each: {points: Array of Vector2(latitude, longitude), oldest first; color: Color}
var paths: Array = []

const PATH_WIDTH = 0.0012
const PATH_DOT = 0.0035

var _quad: MeshInstance3D
var _material: ShaderMaterial
var _vector := VectorMap.new()
var _attribution: Label3D
var _marker_nodes: Array = []
var _paths := MeshInstance3D.new()
var _outlines := BuildingOutlines.new()
var _loader := TileLoader.new()
var _compose_queued = false
var _rendered_view := []
## Collider just above the map surface, so the pointer (and its cursor) lands on the
## map instead of the card behind it. Presses on it bubble up to the map's owner.
var body := StaticBody3D.new()
var _body_shape := CollisionShape3D.new()

func _ready():
	body.collision_mask = 0
	_body_shape.shape = BoxShape3D.new()
	body.add_child(_body_shape)
	add_child(body)

	_material = ShaderMaterial.new()
	_material.shader = MapShader
	# Under the paths (12): it can fade out, which makes it a transparent object.
	_material.render_priority = 11

	_quad = MeshInstance3D.new()
	_quad.mesh = QuadMesh.new()
	_quad.material_override = _material
	add_child(_quad)

	_attribution = attribution_label(Tiles.ATTRIBUTION)
	add_child(_attribution)

	_paths.material_override = PathOverlay.material(false)
	add_child(_paths)

	add_child(_vector)
	_material.set_shader_parameter("map_texture", _vector.get_texture())
	_vector.drawn.connect(_update_texture_mapping)

	add_child(_loader)
	_loader.loaded.connect(_queue_compose)

	_outlines.setup(_loader, false)
	add_child(_outlines)

## Sets [member zoom] and [member magnification] from a fractional zoom level.
func set_fractional_zoom(fractional_zoom: float):
	var split = Tiles.split_zoom(min(fractional_zoom, max_zoom))
	zoom = split[0]
	magnification = split[1]

func get_fractional_zoom() -> float:
	return zoom + log(magnification) / log(2.0)

## Map pixels (at [member zoom]) per meter of panel
func _ppm() -> float:
	return PIXELS_PER_METER / magnification

## Map pixels (at [member zoom]) the map shows
func _px_size() -> Vector2:
	return size * _ppm()

## Zoomed in past the base map: only the rooms (miniature) are shown.
func rooms_only() -> bool:
	return get_fractional_zoom() > Tiles.ROOMS_FROM_ZOOM + 0.0001

## [x, y] world pixels (doubles) of the map's top left corner
func _top_left() -> Array:
	var c = Tiles.project_d(center[0], center[1], zoom)
	return [c[0] - _px_size().x / 2.0, c[1] - _px_size().y / 2.0]

## Local position (meters, on the map plane) of a coordinate.
func to_local_position(latitude: float, longitude: float) -> Vector3:
	var o = Tiles.offset_px(center, [latitude, longitude], zoom) / _ppm()
	return Vector3(o.x, -o.y, 0)

## Where a coordinate lies on the map, as a global transform on the map's surface
## with x pointing east, y up (out of the map) and z south. Its basis carries the
## map's own scale (see [method panel_per_meter] for the map's scale).
func surface_transform(latitude: float, longitude: float) -> Transform3D:
	var o = Tiles.offset_px(center, [latitude, longitude], zoom) / _ppm()
	var local = Transform3D(Basis(Vector3.RIGHT, Vector3.BACK, Vector3.DOWN), Vector3(o.x, -o.y, 0.0005))
	return global_transform * local

## Whether a coordinate lies on the shown part of the map.
func shows(latitude: float, longitude: float) -> bool:
	var o = Tiles.offset_px(center, [latitude, longitude], zoom) / _ppm()
	return _within(o)

## Whether a position (meters of panel from the map centre) lies on the map.
func _within(p: Vector2) -> bool:
	if circular:
		return p.length() <= size.x / 2.0
	return abs(p.x) <= size.x / 2.0 and abs(p.y) <= size.y / 2.0

## Meters of panel per meter of ground at [param latitude]: the map's scale.
func panel_per_meter(latitude: float) -> float:
	return 1.0 / (Tiles.meters_per_pixel(latitude, zoom) * _ppm())

## Largest zoom (up to [param max_zoom]) at which all coordinates fit, with a margin.
func fit_zoom(points: Array, max_zoom := 16) -> int:
	for z in range(max_zoom, Tiles.MIN_ZOOM - 1, -1):
		var lo = Vector2(INF, INF)
		var hi = Vector2(-INF, -INF)
		for point in points:
			var p = Tiles.project(point.x, point.y, z)
			lo = lo.min(p)
			hi = hi.max(p)
		var px = size * PIXELS_PER_METER # unmagnified
		if hi.x - lo.x <= px.x * 0.7 and hi.y - lo.y <= px.y * 0.7:
			return z
	return Tiles.MIN_ZOOM

## Centre (latitude, longitude) and zoom that show all [param points]: [center, zoom].
func fit(points: Array, max_zoom := 16) -> Array:
	var z = fit_zoom(points, max_zoom)
	var lo = Vector2(INF, INF)
	var hi = Vector2(-INF, -INF)
	for point in points:
		var p = Tiles.project(point.x, point.y, z)
		lo = lo.min(p)
		hi = hi.max(p)
	return [Tiles.unproject((lo + hi) / 2.0, z), z]

func refresh():
	if not is_node_ready():
		return
	zoom = clampi(zoom, Tiles.MIN_ZOOM, Tiles.MAX_ZOOM)

	var rooms = rooms_only()
	_quad.visible = not rooms
	_attribution.visible = not rooms
	_quad.mesh.size = size
	# Front face 3 mm above the map: over the paths, under most of the markers
	_body_shape.shape.size = Vector3(size.x, size.y, 0.004)
	_body_shape.position = Vector3(0, 0, 0.001)
	_update_body()
	if circular: # under the circle, its corners are gone
		_attribution.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_attribution.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		_attribution.position = Vector3(0, -size.y / 2.0 - 0.003, 0.001)
	else:
		_attribution.position = Vector3(size.x / 2.0 - 0.006, -size.y / 2.0 + 0.004, 0.001)
	_material.set_shader_parameter("size_px", _px_size())
	_material.set_shader_parameter("corner_radius_px", (size.x / 2.0 if circular else 0.008) * _ppm())

	var fractional_zoom = get_fractional_zoom()
	set_fade(_material, Tiles.map_opacity(fractional_zoom), MapShader, MapFadeShader)
	var outlines_opacity = Tiles.outlines_opacity(fractional_zoom) if building_outlines else 0.0
	_outlines.show_view(center, zoom, _ppm(), outlines_opacity, size / 2.0, circular, 0.0012)

	set_circle_uniforms(_material, circles, _top_left(), zoom)
	_update_markers()
	_update_paths()

	# A state update that doesn't move the map only moves the markers.
	var view = [center, zoom, magnification, size]
	if view != _rendered_view and not rooms: # no drawing hundreds of times the map's size
		_rendered_view = view
		_compose()
	# Until the new drawing is ready, show the last one moved / scaled into place.
	_update_texture_mapping()

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		_update_body()

## Hidden nodes still collide; only catch the pointer while shown.
func _update_body():
	body.collision_layer = 1 if is_visible_in_tree() else 0

func _update_texture_mapping():
	_vector.apply_mapping(_material, _top_left(), zoom)

## Where [param ray] hits the map: offset from the map centre in unmagnified map
## pixels (meters of panel * PIXELS_PER_METER; x right, y down), or null if it
## misses the map's plane.
func ray_offset(ray: RayCast3D):
	var basis_inverse = global_transform.basis.inverse()
	var from = to_local(ray.global_position)
	var direction = basis_inverse * -ray.global_transform.basis.z
	if abs(direction.z) < 0.000001:
		return null
	var t = -from.z / direction.z
	if t < 0:
		return null
	var hit = from + direction * t
	return Vector2(hit.x, -hit.y) * PIXELS_PER_METER

## Whether an offset from [method ray_offset] lies on the map.
func contains_offset(offset: Vector2) -> bool:
	return _within(offset / PIXELS_PER_METER)

func _compose():
	_vector.render(_loader, center, zoom, _px_size(), magnification)

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

func _update_paths():
	var tracks = []
	for path in paths:
		var points = PackedVector3Array()
		for p in path.points:
			points.append(to_local_position(p.x, p.y) + Vector3(0, 0, 0.0015))
		tracks.append({"points": points, "color": path.color})
	_paths.mesh = PathOverlay.build(tracks, Vector3.BACK, PATH_WIDTH, PATH_DOT)
	_paths.material_override.set_shader_parameter("bounds", size / 2.0)
	_paths.material_override.set_shader_parameter("circular", circular)

func _update_markers():
	while _marker_nodes.size() < markers.size():
		var node = create_marker_node()
		add_child(node)
		_marker_nodes.append(node)

	for i in _marker_nodes.size():
		var node: Node3D = _marker_nodes[i]
		if i >= markers.size():
			node.visible = false
			continue
		var position_on_map = to_local_position(markers[i].lat, markers[i].lon)
		# Hide markers whose centre is off the map.
		node.visible = _within(Vector2(position_on_map.x, position_on_map.y))
		node.position = position_on_map + Vector3(0, 0, 0.002 + i * 0.0005)
		apply_marker(node, markers[i])

# ---------------------------------------------------------------------------
# Shared with the 3D map
# ---------------------------------------------------------------------------

## Sets the circle uniforms of the map / terrain shader. Circle centres are in map
## pixels relative to [param top_left] ([x, y] world pixels, doubles).
static func set_circle_uniforms(material: ShaderMaterial, circle_list: Array, top_left: Array, map_zoom: int):
	var centers = []
	var colors = []
	for circle in circle_list.slice(0, 8):
		var p = Tiles.diff(Tiles.project_d(circle.lat, circle.lon, map_zoom), top_left)
		var radius = circle.radius / Tiles.meters_per_pixel(circle.lat, map_zoom)
		centers.append(Vector4(p.x, p.y, radius, 0))
		var color: Color = circle.color
		colors.append(Vector4(color.r, color.g, color.b, color.a))
	while centers.size() < 8:
		centers.append(Vector4.ZERO)
		colors.append(Vector4.ZERO)
	material.set_shader_parameter("circles", centers)
	material.set_shader_parameter("circle_colors", colors)
	material.set_shader_parameter("circle_count", min(circle_list.size(), 8))

## Fades [param material] to [param opacity]: on the transparent [param fade_shader]
## only while it is below 1, so a fully shown map stays an opaque object.
static func set_fade(material: ShaderMaterial, opacity: float, shader: Shader, fade_shader: Shader):
	var wanted = fade_shader if opacity < 0.999 else shader
	if material.shader != wanted:
		material.shader = wanted
	material.set_shader_parameter("opacity", opacity)

static func attribution_label(text: String) -> Label3D:
	var label = Label3D.new()
	label.text = text
	label.font_size = 6
	label.pixel_size = 0.001
	label.outline_size = 0
	label.render_priority = 15
	label.modulate = Color(1, 1, 1, 0.55)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	return label

## A round marker (picture, initials or icon) facing +Z.
static func create_marker_node() -> Node3D:
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
	return node

static func apply_marker(node: Node3D, marker: Dictionary):
	var diameter = marker.get("diameter", 0.028)
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
