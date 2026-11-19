extends RefCounted
## Minimal Mapbox Vector Tile (v2) decoder: https://github.com/mapbox/vector-tile-spec
##
## Decodes only the requested layers; other layers are skipped without parsing their
## features. Thread safe as long as each thread uses its own instance.
##
## Result: {layer name: {"extent": int, "features": [{"type": int, "properties":
## Dictionary, "geometry": Array[PackedVector2Array]}]}} with coordinates in tile
## units (0..extent). Geometry types: 1 point, 2 line, 3 polygon. Polygon rings keep
## their winding: positive area (in y-down tile coordinates) is an exterior ring.

const MOVE_TO = 1
const LINE_TO = 2
const CLOSE_PATH = 7

var _data: PackedByteArray
var _pos := 0

func _init(data: PackedByteArray):
	_data = data

func decode(wanted_layers: Array) -> Dictionary:
	var layers = {}
	_pos = 0
	while _pos < _data.size():
		var key = _varint()
		if key >> 3 == 3 and key & 7 == 2:
			var layer_end = _varint() + _pos
			var layer = _layer(layer_end, wanted_layers)
			if layer != null:
				layers[layer.name] = layer
			_pos = layer_end
		else:
			_skip(key & 7)
	return layers

func _layer(end: int, wanted_layers: Array):
	var name = ""
	var extent = 4096
	var keys = []
	var values = []
	var feature_ranges = []

	while _pos < end:
		var key = _varint()
		match key >> 3:
			1:
				name = _string()
				if not wanted_layers.has(name):
					return null
			2:
				var length = _varint()
				feature_ranges.append(Vector2i(_pos, _pos + length))
				_pos += length
			3:
				keys.append(_string())
			4:
				var value_end = _varint() + _pos
				values.append(_value(value_end))
				_pos = value_end
			5:
				extent = _varint()
			_:
				_skip(key & 7)

	if not wanted_layers.has(name):
		return null

	var features = []
	for feature_range in feature_ranges:
		_pos = feature_range.x
		features.append(_feature(feature_range.y, keys, values))
	return {"name": name, "extent": extent, "features": features}

func _feature(end: int, keys: Array, values: Array) -> Dictionary:
	var type = 0
	var tags = PackedInt64Array()
	var commands = PackedInt64Array()

	while _pos < end:
		var key = _varint()
		match key >> 3:
			2: tags = _packed()
			3: type = _varint()
			4: commands = _packed()
			_: _skip(key & 7)

	var properties = {}
	for i in range(0, tags.size() - 1, 2):
		if tags[i] < keys.size() and tags[i + 1] < values.size():
			properties[keys[tags[i]]] = values[tags[i + 1]]

	return {"type": type, "properties": properties, "geometry": _geometry(commands)}

static func _geometry(commands: PackedInt64Array) -> Array:
	var parts = []
	var current = PackedVector2Array()
	var x = 0
	var y = 0
	var i = 0
	while i < commands.size():
		var command = commands[i]
		i += 1
		var id = command & 7
		var count = command >> 3
		if id == MOVE_TO or id == LINE_TO:
			for c in count:
				if i + 1 >= commands.size():
					break
				x += _zigzag(commands[i])
				y += _zigzag(commands[i + 1])
				i += 2
				if id == MOVE_TO and current.size() > 0:
					parts.append(current)
					current = PackedVector2Array()
				current.append(Vector2(x, y))
		elif id == CLOSE_PATH:
			if current.size() > 0:
				parts.append(current)
			current = PackedVector2Array()
	if current.size() > 0:
		parts.append(current)
	return parts

## Shoelace area in tile coordinates; positive for exterior polygon rings.
static func ring_area(ring: PackedVector2Array) -> float:
	var area = 0.0
	for i in ring.size():
		var a = ring[i]
		var b = ring[(i + 1) % ring.size()]
		area += a.x * b.y - b.x * a.y
	return area / 2.0

# --- protobuf ---------------------------------------------------------------

func _varint() -> int:
	var result = 0
	var shift = 0
	while _pos < _data.size():
		var byte = _data[_pos]
		_pos += 1
		result |= (byte & 0x7F) << shift
		if byte < 0x80:
			break
		shift += 7
	return result

static func _zigzag(n: int) -> int:
	return (n >> 1) ^ -(n & 1)

func _string() -> String:
	var length = _varint()
	var text = _data.slice(_pos, _pos + length).get_string_from_utf8()
	_pos += length
	return text

func _packed() -> PackedInt64Array:
	var end = _varint() + _pos
	var result = PackedInt64Array()
	while _pos < end:
		result.append(_varint())
	return result

func _value(end: int):
	var value = null
	while _pos < end:
		var key = _varint()
		match key >> 3:
			1: value = _string()
			2:
				value = _data.decode_float(_pos)
				_pos += 4
			3:
				value = _data.decode_double(_pos)
				_pos += 8
			4, 5: value = _varint()
			6: value = _zigzag(_varint())
			7: value = _varint() != 0
			_: _skip(key & 7)
	return value

func _skip(wire_type: int):
	match wire_type:
		0: _varint()
		1: _pos += 8
		2: _pos += _varint()
		5: _pos += 4
		_: _pos = _data.size() # unknown wire type: the data is broken, stop
