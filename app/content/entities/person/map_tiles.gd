extends RefCounted
## Map tile sources and the cache shared by every map view.
##
## Tiles use Web Mercator ("slippy map") coordinates. Each layer is cached in memory
## and on disk (user://map_tiles/<layer>) for CACHE_MAX_AGE, so maps that are shown
## again, or several maps of the same area, don't download them again.
##
## Sources and their terms:
## - vector: OpenFreeMap vector tiles (OpenMapTiles schema, OpenStreetMap data).
##   The maps draw these themselves in Home Assistant's colours (vector_map.gd); the
##   3D map also builds its buildings and trees from them. Free with no request limits
##   and no key (https://openfreemap.org). The tile URL contains a data version, so
##   it is read from their TileJSON. (Home Assistant's map card uses CARTO's raster
##   basemaps, but those answer requests from outside a browser with an "API key
##   required" image.)
## - terrain: Terrain Tiles on AWS Open Data (terrarium encoding), elevation for the
##   3D map. Free, no key.

const TILE_SIZE = 256 ## world pixels per tile, also the size of the raster tile images
const USER_AGENT = "User-Agent: ImmersiveHome (Godot)"
const ATTRIBUTION = "© OpenStreetMap contributors · OpenFreeMap © OpenMapTiles"
const ATTRIBUTION_3D = "© OpenStreetMap contributors · OpenFreeMap © OpenMapTiles\nTerrain Tiles (Mapzen, AWS)"
const MIN_ZOOM = 2
const MAX_ZOOM = 19
const VECTOR_MAX_ZOOM = 14 ## vector tiles exist up to this zoom; closer views scale them up
const VECTOR_CACHE_VERSION = 2

const LAYERS = {
	"terrain": {"url": "https://s3.amazonaws.com/elevation-tiles-prod/terrarium/{z}/{x}/{y}.png", "max_zoom": 15, "parallel": 4, "format": "png"},
	"vector": {"tilejson": "https://tiles.openfreemap.org/planet", "max_zoom": 14, "parallel": 2, "format": "vector"},
}

const CACHE_DIR = "user://map_tiles"
const CACHE_MAX_AGE = 30 * 24 * 3600 ## seconds before a cached tile is fetched again
const MEMORY_TILES = 128

static var _memory := {}
static var _memory_order: Array = []
## URL template of the vector layer, read from its TileJSON ("" until known).
static var features_url := ""

static func url(layer: String, z: int, x: int, y: int) -> String:
	var template = features_url if layer == "vector" else LAYERS[layer].url
	return template.replace("{z}", str(z)).replace("{x}", str(x)).replace("{y}", str(y))

static func key(layer: String, z: int, x: int, y: int) -> String:
	return "%s/%d/%d/%d" % [layer, z, x, y]

static func _path(layer: String, z: int, x: int, y: int) -> String:
	if LAYERS[layer].format == "vector":
		# Decoded data: bump VECTOR_CACHE_VERSION whenever map_features.gd changes
		# what it extracts, so old caches aren't used.
		return "%s/%s_v%d/%d/%d/%d.bin" % [CACHE_DIR, layer, VECTOR_CACHE_VERSION, z, x, y]
	return "%s/%s/%d/%d/%d.png" % [CACHE_DIR, layer, z, x, y]

## Position in world pixels (TILE_SIZE per tile) at [param zoom].
static func project(latitude: float, longitude: float, zoom: int) -> Vector2:
	var scale = TILE_SIZE * pow(2.0, zoom)
	var lat = deg_to_rad(clamp(latitude, -85.0511, 85.0511))
	return Vector2(
		(longitude + 180.0) / 360.0 * scale,
		(1.0 - log(tan(lat) + 1.0 / cos(lat)) / PI) / 2.0 * scale
	)

## A fractional zoom as [tile level, magnification]: the map is drawn at the nearest
## whole level and shown that much larger or smaller (between 0.71 and 1.41).
static func split_zoom(fractional_zoom: float) -> Array:
	var z = clamp(fractional_zoom, MIN_ZOOM, MAX_ZOOM)
	var level = clampi(roundi(z), MIN_ZOOM, MAX_ZOOM)
	return [level, pow(2.0, z - level)]

## Inverse of [method project]: Vector2(latitude, longitude).
static func unproject(world_px: Vector2, zoom: int) -> Vector2:
	var scale = TILE_SIZE * pow(2.0, zoom)
	var longitude = world_px.x / scale * 360.0 - 180.0
	var latitude = rad_to_deg(atan(sinh(PI * (1.0 - 2.0 * world_px.y / scale))))
	return Vector2(latitude, longitude)

## World pixels at [param zoom] from [param from] to [param to] (both latitude,
## longitude). Worked out in double precision: Vector2 is single precision, and the
## world pixel values of [method project] lose metres at high zoom levels.
static func offset_px(from: Vector2, to: Vector2, zoom: int) -> Vector2:
	var scale = TILE_SIZE * pow(2.0, zoom)
	var dx = (float(to.y) - float(from.y)) / 360.0 * scale
	var dy = (_mercator_y(to.x) - _mercator_y(from.x)) / 2.0 * scale
	return Vector2(dx, dy)

static func _mercator_y(latitude: float) -> float:
	var lat = deg_to_rad(clamp(latitude, -85.0511, 85.0511))
	return -log(tan(lat) + 1.0 / cos(lat)) / PI

## Ground distance covered by one world pixel at [param latitude] and [param zoom].
static func meters_per_pixel(latitude: float, zoom: int) -> float:
	return 156543.03392 * cos(deg_to_rad(latitude)) / pow(2.0, zoom)

# ---------------------------------------------------------------------------
# Cache. Memory is only touched on the main thread; the disk functions are
# called from worker threads (tile_tasks.gd), so loading never blocks a frame.
# ---------------------------------------------------------------------------

## The tile if it is in memory (an Image, or a Dictionary for "vector"), else null.
## Main thread only.
static func get_memory(layer: String, z: int, x: int, y: int):
	return _memory.get(key(layer, z, x, y))

## Main thread only.
static func remember(layer: String, z: int, x: int, y: int, data):
	var k = key(layer, z, x, y)
	if not _memory.has(k):
		_memory_order.append(k)
	_memory[k] = data
	while _memory_order.size() > MEMORY_TILES:
		_memory.erase(_memory_order.pop_front())

## Reads and decodes a cached tile, or returns null if it isn't cached or too old.
## Thread safe.
static func read_disk(layer: String, z: int, x: int, y: int):
	var path = _path(layer, z, x, y)
	if not FileAccess.file_exists(path):
		return null
	if Time.get_unix_time_from_system() - FileAccess.get_modified_time(path) > CACHE_MAX_AGE:
		return null
	if LAYERS[layer].format == "vector":
		var data = bytes_to_var(FileAccess.get_file_as_bytes(path))
		return data if data is Dictionary else null
	return decode_png(FileAccess.get_file_as_bytes(path))

## Thread safe.
static func decode_png(bytes: PackedByteArray) -> Image:
	var image = Image.new()
	if bytes.is_empty() or image.load_png_from_buffer(bytes) != OK:
		return null
	image.convert(Image.FORMAT_RGBA8)
	return image

## Stores a tile on disk: the PNG for raster layers, the decoded data for "vector".
## Thread safe.
static func write_disk(layer: String, z: int, x: int, y: int, png_or_data):
	var bytes = png_or_data if png_or_data is PackedByteArray else var_to_bytes(png_or_data)
	var path = _path(layer, z, x, y)
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_buffer(bytes)