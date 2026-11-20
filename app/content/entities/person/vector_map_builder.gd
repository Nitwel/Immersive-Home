extends RefCounted
## Prepares a vector_map.gd drawing on a worker thread: transforms every area and
## road into texture pixels and merges them into one triangle list per colour, and
## sorts and filters the labels. The main thread then issues a few dozen draw calls
## instead of thousands, which kept stalling the headset while maps loaded.
##
## Job: tiles ([tile x, tile y, data]), zoom, tile_zoom, top_left (world px),
##      texture_size (px), scale (texture px per map px), zoom_f (zoom including the
##      magnification), pixel_scale (texture px per unmagnified map px), and the
##      styles below.
## Result: id, layers ([points, indices, color] in draw order), labels
##      ([style, text, position] most important first).

const Tiles = preload ("./map_tiles.gd")

static func task(map_ref: WeakRef, job: Dictionary):
	var result = build(job)
	_deliver.call_deferred(map_ref, result)

static func _deliver(map_ref: WeakRef, result: Dictionary):
	var map = map_ref.get_ref()
	if map != null:
		map._on_built(result)

static func build(job: Dictionary) -> Dictionary:
	var layers = []
	var bounds = Rect2(Vector2.ZERO, job.texture_size)
	var transforms = []
	for tile in job.tiles:
		transforms.append(_transform(job, tile[0], tile[1]))

	# Areas: per style its fill, then its holes in the land colour (islands, courtyards).
	for style in job.area_order:
		if style == "building" and job.zoom < job.buildings_min_zoom:
			continue
		var fill = [PackedVector2Array(), PackedInt32Array()]
		var holes = [PackedVector2Array(), PackedInt32Array()]
		for t in job.tiles.size():
			for area in job.tiles[t][2].areas:
				if area[0] == style:
					_append_area(holes if area[3] else fill, transforms[t] * area[1], area[2])
		_add_layer(layers, fill, job.area_colors[style])
		_add_layer(layers, holes, job.background)

	# Lines: all casings first, so crossing roads join cleanly, then the fills.
	var by_style = {}
	for t in job.tiles.size():
		for line in job.tiles[t][2].lines:
			if not by_style.has(line[0]):
				by_style[line[0]] = []
			by_style[line[0]].append(transforms[t] * line[1])

	# Roads grow with the (fractional) zoom, but slower than the map so they stay
	# readable. Widths are in texture pixels of an unmagnified map, so a magnified
	# map doesn't get fat roads.
	var zoom_scale = clamp(pow(2.0, (job.zoom_f - 14) * 0.7), 0.35, 5.0) * job.pixel_scale
	var cull = bounds.grow(8 * job.pixel_scale)
	for pass_casing in [true, false]:
		for style in job.line_order:
			var line_style = job.line_styles[style]
			if job.zoom < line_style[3] or (pass_casing and line_style[1] == null):
				continue
			var width = max(line_style[2] * zoom_scale + (1.6 * job.pixel_scale if pass_casing else 0.0), 1.0)
			var geometry = [PackedVector2Array(), PackedInt32Array()]
			for points in by_style.get(style, []):
				_append_line(geometry, points, width / 2.0, cull)
			_add_layer(layers, geometry, line_style[1] if pass_casing else line_style[0])

	# Labels: on the map only, most important first (the main thread places them).
	var labels = []
	for t in job.tiles.size():
		for label in job.tiles[t][2].labels:
			var position = transforms[t] * label[2]
			if bounds.has_point(position):
				labels.append([label[0], label[1], position, label[3]])
	labels.sort_custom(func(a, b):
		var order_a = job.label_order.find(a[0])
		var order_b = job.label_order.find(b[0])
		return order_a < order_b if order_a != order_b else a[3] < b[3]
	)

	return {"id": job.id, "layers": layers, "labels": labels, "top_left": job.top_left, "zoom": job.zoom, "scale": job.scale}

## Tile units of tile (tx, ty) -> texture pixels.
static func _transform(job: Dictionary, tx: int, ty: int) -> Transform2D:
	var factor = pow(2.0, job.zoom - job.tile_zoom) * Tiles.TILE_SIZE * job.scale
	# top_left is [x, y] doubles; subtract before going to (single precision) Vector2.
	var origin = Vector2(tx * factor - job.top_left[0] * job.scale, ty * factor - job.top_left[1] * job.scale)
	return Transform2D(0.0, Vector2(factor, factor), 0.0, origin)

static func _add_layer(layers: Array, geometry: Array, color: Color):
	if not geometry[1].is_empty():
		layers.append([geometry[0], geometry[1], color])

## Packed arrays are copy-on-write, so they are taken out, changed and stored back.
static func _append_area(geometry: Array, points: PackedVector2Array, indices: PackedInt32Array):
	var vertices: PackedVector2Array = geometry[0]
	var out: PackedInt32Array = geometry[1]
	var base = vertices.size()
	vertices.append_array(points)
	var start = out.size()
	out.resize(start + indices.size())
	for i in indices.size():
		out[start + i] = indices[i] + base
	geometry[0] = vertices
	geometry[1] = out

## A polyline as one quad per segment. Each quad is extended by half the width at
## both ends (square caps), which fills the joints between segments.
static func _append_line(geometry: Array, points: PackedVector2Array, half: float, cull: Rect2):
	var vertices: PackedVector2Array = geometry[0]
	var indices: PackedInt32Array = geometry[1]
	for i in points.size() - 1:
		var a = points[i]
		var b = points[i + 1]
		if not (cull.has_point(a) or cull.has_point(b)):
			continue # segment far off the map
		var d = b - a
		var length = d.length()
		if length < 0.01:
			continue
		var along = d / length * half
		var across = Vector2(-along.y, along.x)
		var base = vertices.size()
		vertices.append(a - along + across)
		vertices.append(b + along + across)
		vertices.append(b + along - across)
		vertices.append(a - along - across)
		indices.append(base); indices.append(base + 1); indices.append(base + 2)
		indices.append(base); indices.append(base + 2); indices.append(base + 3)
	geometry[0] = vertices
	geometry[1] = indices
