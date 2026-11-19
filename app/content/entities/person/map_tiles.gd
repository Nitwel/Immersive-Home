extends RefCounted
## Map tiles in Web Mercator ("slippy map") coordinates, shared by every map view.
##
## Tiles come from openstreetmap.org. Their tile usage policy
## (https://operations.osmfoundation.org/policies/tiles/) asks apps to identify
## themselves in the User-Agent, cache tiles, show the attribution and keep to two
## parallel downloads, which this does. Tiles are kept in memory and on disk so a map
## that is shown again, or several maps of the same area, don't request them again.
##
## (Home Assistant's map card uses CARTO's basemaps, but those now answer requests
## from outside a browser with an "API key required" image.)

const TILE_SIZE = 256 ## world pixels per tile, also the size of the tile images
const STYLE = "osm"
const USER_AGENT = "User-Agent: ImmersiveHome (Godot)"
const ATTRIBUTION = "© OpenStreetMap contributors"
const MAX_PARALLEL_DOWNLOADS = 2
const MIN_ZOOM = 2
const MAX_ZOOM = 19

const CACHE_DIR = "user://map_tiles"
const CACHE_MAX_AGE = 30 * 24 * 3600 ## seconds before a cached tile is fetched again
const MEMORY_TILES = 96 ## 256 KB each

static var _memory := {}
static var _memory_order: Array = []

static func url(z: int, x: int, y: int) -> String:
	return "https://tile.openstreetmap.org/%d/%d/%d.png" % [z, x, y]

static func key(z: int, x: int, y: int) -> String:
	return "%d/%d/%d" % [z, x, y]

## Position in world pixels (TILE_SIZE per tile) at [param zoom].
static func project(latitude: float, longitude: float, zoom: int) -> Vector2:
	var scale = TILE_SIZE * pow(2.0, zoom)
	var lat = deg_to_rad(clamp(latitude, -85.0511, 85.0511))
	return Vector2(
		(longitude + 180.0) / 360.0 * scale,
		(1.0 - log(tan(lat) + 1.0 / cos(lat)) / PI) / 2.0 * scale
	)

## Ground distance covered by one world pixel at [param latitude] and [param zoom].
static func meters_per_pixel(latitude: float, zoom: int) -> float:
	return 156543.03392 * cos(deg_to_rad(latitude)) / pow(2.0, zoom)

## Returns the tile from memory or disk, or null if it has to be downloaded.
static func get_cached(z: int, x: int, y: int) -> Image:
	var k = key(z, x, y)
	if _memory.has(k):
		return _memory[k]

	var path = "%s/%s/%s.png" % [CACHE_DIR, STYLE, k]
	if not FileAccess.file_exists(path):
		return null
	if Time.get_unix_time_from_system() - FileAccess.get_modified_time(path) > CACHE_MAX_AGE:
		return null

	var image = Image.load_from_file(path)
	if image == null or image.is_empty():
		return null
	image.convert(Image.FORMAT_RGBA8)
	_remember(k, image)
	return image

static func store(z: int, x: int, y: int, png: PackedByteArray) -> Image:
	var image = Image.new()
	if image.load_png_from_buffer(png) != OK:
		return null
	image.convert(Image.FORMAT_RGBA8)

	var k = key(z, x, y)
	_remember(k, image)

	var path = "%s/%s/%s.png" % [CACHE_DIR, STYLE, k]
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_buffer(png)
	return image

static func _remember(k: String, image: Image):
	if not _memory.has(k):
		_memory_order.append(k)
	_memory[k] = image
	while _memory_order.size() > MEMORY_TILES:
		_memory.erase(_memory_order.pop_front())
