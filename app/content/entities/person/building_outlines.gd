extends MeshInstance3D
## Footprints of the buildings around the view, drawn as lines on the map. On the
## Map View they fade in as the base map fades out into the rooms (see
## Tiles.outlines_opacity), so the house and its neighbours stay recognisable when
## zoomed in on the miniature.
##
## The lines are built around an anchor, in map pixels at Tiles.MAX_ZOOM, and only
## moved and scaled while the map is dragged or zoomed. They are built anew when the
## view nears the edge of the covered area, or the zoom has changed the line width
## too much.

const Tiles = preload ("./map_tiles.gd")
const PathOverlay = preload ("./path_overlay.gd")
const Builder = preload ("./map_3d_builder.gd")

## Ground meters around the anchor that one build covers
const COVER_RADIUS = 300.0
## Line width in meters of panel
const LINE_WIDTH = 0.0008
const COLOR = Color(1, 1, 1, 0.8)

## 3D map: the map lies in XZ (ground space) instead of XY.
var ground_plane := false

var _loader
var _material: ShaderMaterial
## [latitude, longitude] the lines are built around; null to collect them anew
var _anchor = null
## Footprints: PackedVector2Array in map pixels at MAX_ZOOM from the anchor (x east, y south)
var _rings: Array = []
## Whether all vector tiles were loaded when collecting
var _complete := false
## Panel meters per map pixel at MAX_ZOOM the line width was built for (0: not built)
var _built_scale := 0.0
var _last_view = null

func setup(loader, on_ground: bool):
	_loader = loader
	ground_plane = on_ground
	_material = PathOverlay.material(on_ground)
	_material.render_priority = 13 # over the paths
	material_override = _material
	visible = false
	loader.loaded.connect(func():
		# Tiles came in that the last collection was missing
		if not _complete and _last_view != null:
			_anchor = null
			callv("show_view", _last_view)
	)

## Shows the outlines for a view: [param center] ([latitude, longitude]), tile level
## [param zoom] and [param ppm] (map pixels per meter of panel) as in the maps,
## [param half_size] / [param circular] to clip them to the map, and [param lift]:
## height above the map surface.
func show_view(center, zoom: int, ppm: float, opacity: float, half_size: Vector2, circular: bool, lift: float):
	_last_view = [center, zoom, ppm, opacity, half_size, circular, lift]
	visible = opacity > 0.001
	if not visible:
		return

	var scale_now = pow(2.0, zoom - Tiles.MAX_ZOOM) / ppm # panel m per map px at MAX_ZOOM
	var view_radius = half_size.length() / scale_now * Tiles.meters_per_pixel(center[0], Tiles.MAX_ZOOM)
	if _anchor == null or _ground_distance(center, _anchor) + view_radius > COVER_RADIUS:
		_collect(center)
		_built_scale = 0.0
	# Rebuilt once the line width is off by a fifth
	if _built_scale == 0.0 or abs(log(scale_now / _built_scale)) > 0.2:
		_build_mesh(scale_now)

	var o = Tiles.offset_px(center, _anchor, zoom) / ppm # the anchor on the map, panel m (x east, y south)
	if ground_plane:
		transform = Transform3D(Basis.from_scale(Vector3(scale_now, 1, scale_now)), Vector3(o.x, lift, o.y))
	else:
		transform = Transform3D(Basis.from_scale(Vector3(scale_now, scale_now, 1)), Vector3(o.x, -o.y, lift))
	_material.set_shader_parameter("map_from_model", Projection(transform))
	_material.set_shader_parameter("bounds", half_size)
	_material.set_shader_parameter("circular", circular)
	_material.set_shader_parameter("opacity", opacity)

static func _ground_distance(a, b) -> float:
	return Tiles.offset_px(a, b, Tiles.MAX_ZOOM).length() * Tiles.meters_per_pixel(a[0], Tiles.MAX_ZOOM)

func _collect(center):
	_anchor = [float(center[0]), float(center[1])]
	var radius_px = COVER_RADIUS / Tiles.meters_per_pixel(_anchor[0], Tiles.MAX_ZOOM)
	var tiles = _loader.tiles_around("vector", _anchor, Tiles.MAX_ZOOM, Vector2.ONE * 2.0 * radius_px, Tiles.VECTOR_MAX_ZOOM)
	_complete = tiles.missing == 0

	var anchor_px = Tiles.project_d(_anchor[0], _anchor[1], Tiles.MAX_ZOOM)
	var factor = Tiles.TILE_SIZE * pow(2.0, Tiles.MAX_ZOOM - Tiles.VECTOR_MAX_ZOOM) # map px per tile
	_rings = []
	for tile in tiles.tiles:
		# Doubles until here: tile corner relative to the anchor
		var origin = Vector2(tile[0] * factor - anchor_px[0], tile[1] * factor - anchor_px[1])
		for building in tile[2].buildings:
			var ring: PackedVector2Array = building[2]
			if not Builder._owns(ring): # repeated near tile edges
				continue
			var points = PackedVector2Array()
			for p in ring:
				points.append(origin + p * factor)
			if points[0].length() <= radius_px * 1.2:
				_rings.append(points)

func _build_mesh(scale_now: float):
	_built_scale = scale_now
	var tracks = []
	for ring in _rings:
		var points = PackedVector3Array()
		for p in ring:
			points.append(Vector3(p.x, 0, p.y) if ground_plane else Vector3(p.x, -p.y, 0))
		points.append(points[0])
		tracks.append({"points": points, "color": COLOR})
	mesh = PathOverlay.build(tracks, Vector3.UP if ground_plane else Vector3.BACK, LINE_WIDTH / scale_now, 0.0, false)
