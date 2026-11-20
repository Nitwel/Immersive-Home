extends RefCounted
## Worker thread tasks of tile_loader.gd: reading the disk cache and decoding
## downloads (PNG images, vector tiles). Results go back to the main thread with
## call_deferred. The tasks only hold a weak reference to the loader, so a map that
## was closed meanwhile is simply skipped.

const Tiles = preload ("./map_tiles.gd")
const Features = preload ("./map_features.gd")

## Loads a tile from the disk cache, or asks the loader to download it.
static func load_task(loader_ref: WeakRef, layer: String, z: int, x: int, y: int):
	var data = Tiles.read_disk(layer, z, x, y)
	if data != null:
		_deliver.call_deferred(loader_ref, layer, z, x, y, data)
	else:
		_download.call_deferred(loader_ref, layer, z, x, y)

## Decodes a downloaded tile and stores it on disk.
static func decode_task(loader_ref: WeakRef, layer: String, z: int, x: int, y: int, body: PackedByteArray):
	var data = null
	if Tiles.LAYERS[layer].format == "vector":
		data = Features.from_pbf(body)
		Tiles.write_disk(layer, z, x, y, data)
	else:
		data = Tiles.decode_png(body)
		if data != null:
			Tiles.write_disk(layer, z, x, y, body)

	if data != null:
		_deliver.call_deferred(loader_ref, layer, z, x, y, data)
	else:
		_failed.call_deferred(loader_ref, layer, z, x, y, "could not decode")

static func _deliver(loader_ref: WeakRef, layer: String, z: int, x: int, y: int, data):
	Tiles.remember(layer, z, x, y, data)
	var loader = loader_ref.get_ref()
	if loader != null:
		loader._on_tile_ready(layer, z, x, y)

static func _download(loader_ref: WeakRef, layer: String, z: int, x: int, y: int):
	var loader = loader_ref.get_ref()
	if loader != null:
		loader._queue_download(layer, z, x, y)

static func _failed(loader_ref: WeakRef, layer: String, z: int, x: int, y: int, reason: String):
	var loader = loader_ref.get_ref()
	if loader != null:
		loader._fail(Tiles.key(layer, z, x, y), reason)
