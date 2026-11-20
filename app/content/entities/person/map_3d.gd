extends Node3D
## 3D map: a small tilted diorama of the area around [member center].
##
## - Terrain: a grid raised by the Terrain Tiles height map (exaggerated, since
##   relief is tiny at this scale), textured with the vector map (vector_map.gd),
##   with sides so it reads as a block.
## - Buildings from OpenFreeMap vector tiles, extruded to their height, once zoomed
##   in to map_3d_builder.gd's BUILDINGS_MIN_ZOOM.
## - Low-poly trees scattered in woods and parks.
## - Markers as pins standing on the terrain; zones and GPS accuracy as circles.
##
## The geometry is built on a worker thread (map_3d_builder.gd); this node only
## snapshots the inputs, uploads the finished arrays and places the pins.
##
## Same interface as map_view.gd: set size, center, zoom, markers and circles, then
## call refresh(). The node's origin is the back edge of the diorama, which is
## tilted towards the viewer by [member tilt].

const Tiles = preload ("./map_tiles.gd")
const TileLoader = preload ("./tile_loader.gd")
const MapView = preload ("./map_view.gd")
const VectorMap = preload ("./vector_map.gd")
const Builder = preload ("./map_3d_builder.gd")
const PathOverlay = preload ("./path_overlay.gd")
const BuildingOutlines = preload ("./building_outlines.gd")
const DioramaShader = preload ("./diorama.gdshader")
const DioramaFadeShader = preload ("./diorama_fade.gdshader")

const PIXELS_PER_METER = Builder.PIXELS_PER_METER
const PIN_HEIGHT = 0.022
const SIDE_COLOR = Color(0.16, 0.16, 0.17)
const TREE_COLOR = Color8(130, 186, 118)

## Footprint in meters of panel: width x depth.
var size := Vector2(0.28, 0.2)
var tilt := deg_to_rad(50.0)
## Round diorama: a disc of diameter size.x (keep size square) instead of a block.
var circular := false
## [latitude, longitude] doubles; a Vector2 can be assigned too (see map_view.gd).
var center = [0.0, 0.0]:
	set(value):
		center = [float(value[0]), float(value[1])]
## Highest fractional zoom, as in map_view.gd: past Tiles.ROOMS_FROM_ZOOM only the
## pins, paths and the miniature house are left.
var max_zoom := float(Tiles.MAX_ZOOM)
## Draw building footprints when zoomed in close (Map View, see building_outlines.gd).
var building_outlines := false
var zoom := 16
## How much larger the map is shown than its tile level (fractional zoom, see
## [method set_fractional_zoom]).
var magnification := 1.0
var markers: Array = []
var circles: Array = []
## History paths, as in map_view.gd: {points: Array of Vector2(lat, lon), color}
var paths: Array = []

const PATH_WIDTH = 0.0012
const PATH_DOT = 0.003
## Width in meters of panel of the outlines drawn by set_ghost.
const GHOST_LINE = 0.0005

## [latitude, longitude, radius m] of set_ghost, or null
var _ghost = null
## How far up the terrain, buildings and trees stand: 1, flattening to 0 into the
## rooms (Tiles.map_opacity)
var _flatten := 1.0

## How long a build waits for missing terrain tiles while a map is already shown,
## instead of flattening the terrain until they arrive.
const TERRAIN_WAIT = 1.5

var _ground := Node3D.new()
## The built terrain top, buildings and trees. Moved and scaled to line up with the
## current view while the next build is on its way (dragging, zooming).
var _content := Node3D.new()
var _sides := MeshInstance3D.new()
var _paths := MeshInstance3D.new()
var _outlines := BuildingOutlines.new()
var _terrain := MeshInstance3D.new()
var _buildings := MeshInstance3D.new()
var _trees := MultiMeshInstance3D.new()
var _terrain_material: ShaderMaterial
var _side_material: ShaderMaterial
var _vector := VectorMap.new()
var _attribution: Label3D
var _pins: Array = []
var _loader := TileLoader.new()

## Terrain height in meters of panel at the grid points (from the shown build).
var _heights := {}
## [center, zoom, size, tilt] the map was last asked to show.
var _built_view := []
var _building := false
var _build_again := false
var _terrain_wait_start := -1
## Collider on the terrain's surface, so the pointer (and its cursor) lands on the
## map instead of the card behind it. Presses on it bubble up to the map's owner.
var body := StaticBody3D.new()
var _body_shape := CollisionShape3D.new()
## The view the shown build was made for (world px top left, zoom, size); null before the first.
var _shown = null

func _ready():
	add_child(_ground)
	_ground.add_child(_content)
	for node in [_terrain, _buildings, _trees, body]:
		_content.add_child(node)
	body.collision_mask = 0
	_body_shape.shape = ConcavePolygonShape3D.new()
	_body_shape.shape.backface_collision = true
	body.add_child(_body_shape)
	_ground.add_child(_sides)
	_ground.add_child(_paths)
	_paths.material_override = PathOverlay.material(true)

	_terrain_material = _material(Color.WHITE)
	_terrain_material.set_shader_parameter("use_texture", true)
	_side_material = _material(SIDE_COLOR)
	_sides.material_override = _side_material
	_buildings.material_override = _material(Color.WHITE)
	_buildings.material_override.set_shader_parameter("use_vertex_color", true)
	_trees.material_override = _material(TREE_COLOR)
	_terrain.material_override = _terrain_material

	var cone = CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.35
	cone.height = 1.0
	cone.radial_segments = 6
	cone.rings = 1
	_trees.multimesh = MultiMesh.new()
	_trees.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	_trees.multimesh.mesh = cone

	add_child(_vector)
	_terrain_material.set_shader_parameter("map_texture", _vector.get_texture())
	_vector.drawn.connect(_update_texture_mapping)

	_attribution = MapView.attribution_label(Tiles.ATTRIBUTION_3D)
	add_child(_attribution)

	add_child(_loader)
	_outlines.setup(_loader, true)
	_ground.add_child(_outlines)

	_loader.loaded.connect(func():
		_update_texture()
		_build()
	)

static func _material(color: Color) -> ShaderMaterial:
	var material = ShaderMaterial.new()
	material.shader = DioramaShader
	# Under the paths (12): while fading out it is a transparent object.
	material.render_priority = 11
	material.set_shader_parameter("base_color", color)
	return material

func refresh():
	if not is_node_ready():
		return
	zoom = clampi(zoom, Tiles.MIN_ZOOM, Tiles.MAX_ZOOM)

	# Origin at the back edge; the far (north) side stays at the card.
	_ground.rotation = Vector3(tilt, 0, 0)
	_ground.position = Vector3(0, -size.y / 2.0 * sin(tilt), size.y / 2.0 * cos(tilt))
	# Under the front edge, which sits in front of the card
	_attribution.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_attribution.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if circular else HORIZONTAL_ALIGNMENT_RIGHT
	_attribution.position = Vector3(0.0 if circular else size.x / 2.0, -size.y * sin(tilt) - Builder.BASE_THICKNESS - 0.002, size.y * cos(tilt))

	var rooms = rooms_only()
	_content.visible = not rooms
	_sides.visible = not rooms
	_attribution.visible = not rooms
	# Into the rooms the diorama flattens onto the plate (no jump in height for the
	# pins and the miniature) and the terrain fades out; buildings and trees stay solid
	# and sink into their footprints (building_outlines.gd).
	var fractional_zoom = get_fractional_zoom()
	_flatten = Tiles.map_opacity(fractional_zoom)
	for material in [_terrain_material, _side_material]:
		MapView.set_fade(material, Tiles.map_opacity(fractional_zoom), DioramaShader, DioramaFadeShader)
	var outlines_opacity = Tiles.outlines_opacity(fractional_zoom) if building_outlines else 0.0
	# On the terrain in the middle while it still shows; it is flat enough this close.
	_outlines.show_view(center, zoom, _ppm(), outlines_opacity, size / 2.0, circular, _height_at(Vector2.ZERO) + 0.0012)

	_place_content()
	_update_circles()
	_update_pins()
	_update_paths()

	# A state update that doesn't move the map only moves the pins and circles.
	var view = [center, zoom, magnification, size, tilt, circular]
	if view == _built_view or rooms: # rooms only: nothing to build
		return
	_built_view = view
	_update_texture()
	_build()

## Sets [member zoom] and [member magnification] from a fractional zoom level.
func set_fractional_zoom(fractional_zoom: float):
	var split = Tiles.split_zoom(min(fractional_zoom, max_zoom))
	zoom = split[0]
	magnification = split[1]

func get_fractional_zoom() -> float:
	return zoom + log(magnification) / log(2.0)

## Zoomed in past the base map: only the rooms (miniature) are shown.
func rooms_only() -> bool:
	return get_fractional_zoom() > Tiles.ROOMS_FROM_ZOOM + 0.0001

## Map pixels (at [member zoom]) per meter of panel
func _ppm() -> float:
	return PIXELS_PER_METER / magnification

## Where [param ray] hits the diorama's base plane: offset from the map centre in
## unmagnified map pixels (meters of panel * PIXELS_PER_METER; x east, y south), or
## null if it misses the plane.
func ray_offset(ray: RayCast3D):
	var basis_inverse = _ground.global_transform.basis.inverse()
	var from = _ground.to_local(ray.global_position)
	var direction = basis_inverse * -ray.global_transform.basis.z
	if abs(direction.y) < 0.000001:
		return null
	var t = -from.y / direction.y
	if t < 0:
		return null
	var hit = from + direction * t
	return Vector2(hit.x, hit.z) * PIXELS_PER_METER

## Where a coordinate lies on the terrain, as a global transform with x pointing
## east, y up (out of the ground) and z south. Same as map_view.gd's.
func surface_transform(latitude: float, longitude: float) -> Transform3D:
	var p = Tiles.offset_px(center, Vector2(latitude, longitude), zoom) / _ppm()
	return _ground.global_transform * Transform3D(Basis.IDENTITY, Vector3(p.x, _height_at(p), p.y))

## Draws the buildings whose centre lies within [param radius] meters of a
## coordinate as outlines only, e.g. where the miniature house stands.
func set_ghost(latitude: float, longitude: float, radius: float):
	_ghost = [latitude, longitude, radius]
	_update_ghost()

func clear_ghost():
	if _ghost != null:
		_ghost = null
		_update_ghost()

func _update_ghost():
	var material: ShaderMaterial = _buildings.material_override
	if material == null:
		return
	material.set_shader_parameter("ghost", _ghost != null)
	if _ghost == null:
		return
	# The buildings mesh is in the shown build's ground units; map into those.
	var mapping = _content_mapping()
	var p = Tiles.offset_px(center, Vector2(_ghost[0], _ghost[1]), zoom) / _ppm()
	var radius = _ghost[2] / (Tiles.meters_per_pixel(_ghost[0], zoom) * _ppm())
	material.set_shader_parameter("ghost_center", (p - mapping[1]) / mapping[0])
	material.set_shader_parameter("ghost_radius", radius / mapping[0])
	material.set_shader_parameter("ghost_line", GHOST_LINE / mapping[0])

## Whether a coordinate lies on the shown part of the map.
func shows(latitude: float, longitude: float) -> bool:
	var p = Tiles.offset_px(center, Vector2(latitude, longitude), zoom) / _ppm()
	return _within(p)

## Whether a ground position (meters of panel from the centre) lies on the map.
func _within(p: Vector2) -> bool:
	if circular:
		return p.length() <= size.x / 2.0
	return abs(p.x) <= size.x / 2.0 and abs(p.y) <= size.y / 2.0

## Meters of panel per meter of ground at [param latitude]: the map's scale.
func panel_per_meter(latitude: float) -> float:
	return 1.0 / (Tiles.meters_per_pixel(latitude, zoom) * _ppm())

## Whether an offset from [method ray_offset] lies on the map.
func contains_offset(offset: Vector2) -> bool:
	return _within(offset / PIXELS_PER_METER)

func _px_size() -> Vector2:
	return size * _ppm()

## [x, y] world pixels (doubles) of the map's top left corner
func _top_left() -> Array:
	var c = Tiles.project_d(center[0], center[1], zoom)
	return [c[0] - _px_size().x / 2.0, c[1] - _px_size().y / 2.0]

func _update_texture():
	_vector.render(_loader, center, zoom, _px_size(), magnification)

## The terrain's UVs are in the shown build's pixels; the drawing can be for another view.
func _update_texture_mapping():
	if _shown == null:
		return
	_vector.apply_mapping(_terrain_material, _shown.top_left, _shown.zoom)
	_terrain_material.set_shader_parameter("size_px", _shown.size * _shown.ppm)

func _update_circles():
	if _shown != null:
		MapView.set_circle_uniforms(_terrain_material, circles, _shown.top_left, _shown.zoom)

## Lines the shown build up with the current view: a point of the build at ground
## position p is now at p * scale + offset (ground x / z; heights scale too).
func _content_mapping() -> Array:
	if _shown == null:
		return [1.0, Vector2.ZERO]
	var level_scale = pow(2.0, zoom - _shown.zoom) # shown map px -> current map px
	var scale = level_scale * _shown.ppm / _ppm()
	# The big world pixel values are subtracted first; they cancel out when unmoved.
	var top_left = _top_left()
	var moved_px = Vector2(_shown.top_left[0] * level_scale - top_left[0], _shown.top_left[1] * level_scale - top_left[1])
	var offset = (moved_px + _shown.size / 2.0 * _shown.ppm * level_scale) / _ppm() - size / 2.0
	return [scale, offset]

func _place_content():
	var mapping = _content_mapping()
	# Never quite 0: a flat basis can't be inverted.
	var height = max(_flatten, 0.001)
	_content.transform = Transform3D(Basis.from_scale(Vector3(mapping[0], mapping[0] * height, mapping[0])), Vector3(mapping[1].x, 0, mapping[1].y))
	_sides.scale = Vector3(1, height, 1)
	var moved = not _content.transform.is_equal_approx(Transform3D.IDENTITY)
	for material in [_terrain_material, _buildings.material_override, _trees.material_override]:
		material.set_shader_parameter("clip", moved)
		material.set_shader_parameter("half_size", size / 2.0)
		material.set_shader_parameter("circular", circular)
	# Right before drawing rather than in _process, which can run before the card is
	# moved in the same frame: the cut edges would trail a frame behind and flicker.
	var updating = RenderingServer.frame_pre_draw.is_connected(_update_clip)
	if moved and not updating:
		RenderingServer.frame_pre_draw.connect(_update_clip)
	elif not moved and updating:
		RenderingServer.frame_pre_draw.disconnect(_update_clip)
	if moved:
		_update_clip()
	_update_body()
	_update_ghost()

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		_update_body()

## Hidden nodes still collide; only catch the pointer while shown. Off as well while
## a zoom waits for its build: physics doesn't follow scaled shapes reliably.
func _update_body():
	var unscaled = is_equal_approx(_content.scale.x, 1.0) and is_equal_approx(_content.scale.y, 1.0)
	body.collision_layer = 1 if is_visible_in_tree() and unscaled and _shown != null and not rooms_only() else 0

## Keeps the clipping in place while the map is moved around the room.
func _update_clip():
	if not is_inside_tree():
		return
	var ground_from_world = Projection(_ground.global_transform.affine_inverse())
	for material in [_terrain_material, _buildings.material_override, _trees.material_override]:
		material.set_shader_parameter("ground_from_world", ground_from_world)

## Terrain height at a ground position of the current view.
func _height_at(p: Vector2) -> float:
	if _shown == null or rooms_only(): # no terrain shown
		return 0.0
	var mapping = _content_mapping()
	return Builder.height_at(_heights, (p - mapping[1]) / mapping[0]) * mapping[0] * _flatten

# ---------------------------------------------------------------------------
# Building on a worker thread
# ---------------------------------------------------------------------------

func _build():
	if _building:
		_build_again = true # newer inputs: build once more when this one is done
		return

	var terrain_zoom = mini(zoom, Builder.TERRAIN_MAX_ZOOM)
	var terrain = _loader.tiles_around("terrain", center, zoom, _px_size(), terrain_zoom)

	# Dragged onto new terrain tiles: keep showing the moved map for a moment rather
	# than flattening the terrain until they are downloaded. The loader's loaded
	# signal builds again; the timer is for tiles that fail.
	if terrain.missing > 0 and _shown != null:
		var now = Time.get_ticks_msec()
		if _terrain_wait_start < 0:
			_terrain_wait_start = now
			get_tree().create_timer(TERRAIN_WAIT + 0.05).timeout.connect(_on_terrain_wait_over)
		if now - _terrain_wait_start < TERRAIN_WAIT * 1000:
			return
	_terrain_wait_start = -1

	_building = true
	_build_again = false

	var terrain_tiles = null
	if terrain.missing == 0:
		terrain_tiles = {}
		for tile in terrain.tiles:
			terrain_tiles[Vector2i(tile[0], tile[1])] = tile[2]

	var job = {
		"size": size,
		"circular": circular,
		"zoom": zoom,
		"top_left": _top_left(),
		"latitude": center[0],
		"ppm": _ppm(),
		# Same zoom: keep the shown terrain's base height and relief (see Builder._heights)
		"relief": _shown.relief if _shown != null and _shown.zoom == zoom and is_equal_approx(_shown.ppm, _ppm()) else null,
		"scale": 1.0 / (Tiles.meters_per_pixel(center[0], zoom) * _ppm()),
		"terrain_zoom": terrain_zoom,
		"terrain_tiles": terrain_tiles,
		"vector_tiles": _loader.tiles_around("vector", center, zoom, _px_size(), Tiles.VECTOR_MAX_ZOOM).tiles if zoom >= Builder.TREES_MIN_ZOOM else [],
		"view": _built_view,
	}
	WorkerThreadPool.add_task(Builder.task.bind(weakref(self), job))

func _on_terrain_wait_over():
	if _terrain_wait_start >= 0 and not _building:
		_build()

## Back on the main thread: upload the finished arrays. Builds run one after another,
## so this is newer than what is shown even if the view moved on meanwhile; it is
## shown moved into place (_place_content) until the next one arrives.
func _on_built(result: Dictionary):
	_building = false
	if _build_again:
		_build()

	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, result.terrain)
	_terrain.mesh = mesh
	var sides = ArrayMesh.new()
	sides.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, result.sides)
	_sides.mesh = sides
	_body_shape.shape.set_faces(result.faces)
	_shown ={"top_left": result.top_left, "zoom": result.zoom, "size": result.size, "ppm": result.ppm, "relief": result.heights.relief}

	if result.buildings != null:
		var buildings = ArrayMesh.new()
		# CUSTOM0 holds the outline data (see Builder._building_arrays)
		buildings.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, result.buildings, [], {},
			Mesh.ARRAY_CUSTOM_RGBA_FLOAT << Mesh.ARRAY_FORMAT_CUSTOM0_SHIFT)
		_buildings.mesh = buildings
	else:
		_buildings.mesh = null

	_trees.multimesh.instance_count = result.tree_count
	if result.tree_count > 0:
		_trees.multimesh.buffer = result.trees

	_heights = result.heights
	_place_content()
	_update_texture_mapping()
	_update_circles()
	_update_pins()
	_update_paths()

## Paths lie just above the terrain, so they follow hills.
func _update_paths():
	var tracks = []
	for path in paths:
		var points = PackedVector3Array()
		for latlon in path.points:
			var p = Tiles.offset_px(center, latlon, zoom) / _ppm()
			points.append(Vector3(p.x, _height_at(p) + 0.0015, p.y))
		tracks.append({"points": points, "color": path.color})
	_paths.mesh = PathOverlay.build(tracks, Vector3.UP, PATH_WIDTH, PATH_DOT)
	_paths.material_override.set_shader_parameter("bounds", size / 2.0)
	_paths.material_override.set_shader_parameter("circular", circular)

# ---------------------------------------------------------------------------
# Pins
# ---------------------------------------------------------------------------

func _update_pins():
	while _pins.size() < markers.size():
		_pins.append(_create_pin())

	for i in _pins.size():
		var pin: Node3D = _pins[i]
		if i >= markers.size():
			pin.visible = false
			continue
		var marker = markers[i]
		var p = Tiles.offset_px(center, [marker.lat, marker.lon], zoom) / _ppm()
		pin.visible = _within(p)
		# Later markers (the person) stand a bit taller than earlier ones (home).
		var height = PIN_HEIGHT * (0.6 if i < markers.size() - 1 else 1.0)
		pin.position = Vector3(p.x, _height_at(p), p.y)
		var stick: MeshInstance3D = pin.get_node("Stick")
		stick.mesh.height = height
		stick.position.y = height / 2.0
		var head: Node3D = pin.get_node("Head")
		head.position.y = height
		MapView.apply_marker(head, marker)

func _create_pin() -> Node3D:
	var pin = Node3D.new()

	var stick = MeshInstance3D.new()
	stick.name = "Stick"
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 0.0006
	cylinder.bottom_radius = 0.0006
	cylinder.radial_segments = 6
	cylinder.rings = 1
	stick.mesh = cylinder
	stick.material_override = _material(Color(0.95, 0.95, 0.95))
	pin.add_child(stick)

	var head = MapView.create_marker_node()
	head.name = "Head"
	# Undo the diorama's tilt so the marker faces the viewer like the card does.
	head.rotation.x = -tilt
	pin.add_child(head)

	_ground.add_child(pin)
	return pin
