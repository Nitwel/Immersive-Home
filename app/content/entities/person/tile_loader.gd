extends Node
## Finds the tiles a map view needs and gets them into the shared cache
## (map_tiles.gd): from disk or by downloading, respecting each source's parallel
## download limit.
##
## Nothing heavy runs on the main thread: disk reads and decoding happen in
## tile_tasks.gd on worker threads, and the HTTP requests use their own threads.
## Arriving tiles are batched into one [signal loaded] every LOADED_INTERVAL, so a
## map redraws a few times while loading instead of once per tile.

const Tiles = preload ("./map_tiles.gd")
const TileTasks = preload ("./tile_tasks.gd")

signal loaded()

const TILEJSON_CACHE = "user://map_tiles/features_tilejson.json"
const TILEJSON_MAX_AGE = 24 * 3600
const LOADED_INTERVAL = 0.25

var _queues := {} ## layer -> Array of [z, x, y] waiting for a download slot
var _active := {} ## layer -> running downloads
var _pending := {} ## tile key -> true while loading, downloading or decoding
var _failed := {} ## tile key -> true; not retried while this view exists
var _tilejson_loading = false
var _loaded_scheduled = false

## Returns the tile if it is in memory; otherwise starts loading it and returns null.
func get_tile(layer: String, z: int, x: int, y: int):
	var data = Tiles.get_memory(layer, z, x, y)
	if data == null:
		_request(layer, z, x, y)
	return data

## The tiles of [param layer] covering a map of [param px_size] map pixels around
## [param center] (latitude, longitude: Vector2 or array of doubles) at [param zoom],
## as [tile x, tile y, data] (tile x unwrapped, so it lines up with the map).
## Missing tiles are requested; [code]missing[/code] counts them.
func tiles_around(layer: String, center, zoom: int, px_size: Vector2, tile_zoom: int) -> Dictionary:
	var factor = pow(2.0, zoom - tile_zoom) * Tiles.TILE_SIZE
	var c = Tiles.project_d(center[0], center[1], zoom)
	var lo = Vector2(floorf((c[0] - px_size.x / 2.0) / factor), floorf((c[1] - px_size.y / 2.0) / factor))
	var hi = Vector2(floorf((c[0] + px_size.x / 2.0) / factor), floorf((c[1] + px_size.y / 2.0) / factor))
	var count = 1 << tile_zoom
	var tiles = []
	var missing = 0
	for ty in range(int(lo.y), int(hi.y) + 1):
		if ty < 0 or ty >= count:
			continue
		for tx in range(int(lo.x), int(hi.x) + 1):
			var data = get_tile(layer, tile_zoom, posmod(tx, count), ty)
			if data == null:
				missing += 1
			else:
				tiles.append([tx, ty, data])
	return {"tiles": tiles, "missing": missing}

func _request(layer: String, z: int, x: int, y: int):
	var k = Tiles.key(layer, z, x, y)
	if _pending.has(k) or _failed.has(k):
		return
	_pending[k] = true
	WorkerThreadPool.add_task(TileTasks.load_task.bind(weakref(self), layer, z, x, y))

## Not on disk: download it (called back from TileTasks.load_task).
func _queue_download(layer: String, z: int, x: int, y: int):
	if not _queues.has(layer):
		_queues[layer] = []
		_active[layer] = 0
	_queues[layer].append([z, x, y])
	_start(layer)

func _start(layer: String):
	if layer == "vector" and Tiles.features_url == "":
		_load_tilejson()
		return

	while _active[layer] < Tiles.LAYERS[layer].parallel and not _queues[layer].is_empty():
		var t = _queues[layer].pop_front()
		_download(layer, t[0], t[1], t[2])

func _download(layer: String, z: int, x: int, y: int):
	var k = Tiles.key(layer, z, x, y)
	var http = HTTPRequest.new()
	http.timeout = 20
	http.use_threads = true # network and gzip off the main thread
	add_child(http)
	_active[layer] += 1

	http.request_completed.connect(func(result, code, _headers, body):
		http.queue_free()
		_active[layer] -= 1
		if result != HTTPRequest.RESULT_SUCCESS or code != 200:
			_fail(k, "result %d, HTTP %d" % [result, code])
		else:
			WorkerThreadPool.add_task(TileTasks.decode_task.bind(weakref(self), layer, z, x, y, body))
		_start(layer)
	)
	if http.request(Tiles.url(layer, z, x, y), [Tiles.USER_AGENT]) != OK:
		http.queue_free()
		_active[layer] -= 1
		_fail(k, "request failed")

## A tile is in the cache now (called back from tile_tasks.gd).
func _on_tile_ready(layer: String, z: int, x: int, y: int):
	_pending.erase(Tiles.key(layer, z, x, y))
	if _loaded_scheduled or not is_inside_tree():
		return
	_loaded_scheduled = true
	get_tree().create_timer(LOADED_INTERVAL).timeout.connect(func():
		_loaded_scheduled = false
		loaded.emit()
	)

func _fail(k: String, reason: String):
	_pending.erase(k)
	_failed[k] = true
	push_warning("Map tile %s failed: %s" % [k, reason])

## Reads the current vector tile URL from OpenFreeMap's TileJSON (cached for a day).
func _load_tilejson():
	if _tilejson_loading:
		return

	if FileAccess.file_exists(TILEJSON_CACHE) \
			and Time.get_unix_time_from_system() - FileAccess.get_modified_time(TILEJSON_CACHE) < TILEJSON_MAX_AGE:
		if _apply_tilejson(FileAccess.get_file_as_string(TILEJSON_CACHE)):
			_start("vector")
			return

	_tilejson_loading = true
	var http = HTTPRequest.new()
	http.use_threads = true
	add_child(http)
	http.request_completed.connect(func(result, code, _headers, body):
		http.queue_free()
		_tilejson_loading = false
		var text = body.get_string_from_utf8()
		if result == HTTPRequest.RESULT_SUCCESS and code == 200 and _apply_tilejson(text):
			var file = FileAccess.open(TILEJSON_CACHE, FileAccess.WRITE)
			if file != null:
				file.store_string(text)
			_start("vector")
		else:
			push_warning("Map: could not load the vector tile index (result %d, HTTP %d)" % [result, code])
			for t in _queues["vector"]:
				_fail(Tiles.key("vector", t[0], t[1], t[2]), "no tile index")
			_queues["vector"].clear()
	)
	DirAccess.make_dir_recursive_absolute(TILEJSON_CACHE.get_base_dir())
	if http.request(Tiles.LAYERS.vector.tilejson, [Tiles.USER_AGENT]) != OK:
		http.queue_free()
		_tilejson_loading = false

static func _apply_tilejson(text: String) -> bool:
	var json = JSON.parse_string(text)
	if json is Dictionary and json.get("tiles") is Array and not json.tiles.is_empty():
		Tiles.features_url = str(json.tiles[0])
		return true
	return false
