extends RefCounted
## Builds the 3D map's geometry on a worker thread: terrain heights and mesh,
## extruded buildings and tree positions. Pure data in, mesh arrays out; nothing
## here touches the scene tree or creates GPU resources, so the headset keeps its
## frame rate while it runs. map_3d.gd turns the result into meshes.
##
## Job (a snapshot taken on the main thread):
##   size, zoom, top_left (world px), ppm (map px per panel m), scale (panel m per
##   real m), relief ([lowest m, scale] of the shown build to keep while dragging, or null),
##   terrain_zoom, terrain_tiles ({Vector2i: Image}, null when not all loaded),
##   vector_tiles ([tile x, tile y, data] at VECTOR zoom)
## Result:
##   heights, terrain (surface arrays), sides (surface arrays),
##   buildings (surface arrays or null), trees (MultiMesh buffer), tree_count

const Tiles = preload ("./map_tiles.gd")

const PIXELS_PER_METER = 1600.0
const GRID = 48 ## terrain grid cells per side
const TERRAIN_MAX_ZOOM = 15
const BUILDINGS_MIN_ZOOM = 15
const TREES_MIN_ZOOM = 14

const BASE_THICKNESS = 0.006
const TERRAIN_EXAGGERATION = 2.0
const MAX_RELIEF = 0.04 ## meters of panel; steeper terrain is scaled down to this
const BUILDING_EXAGGERATION = 1.5
const TREE_HEIGHT = 12.0 ## meters in reality
const MIN_TREE_SIZE = 0.0025 ## meters of panel, so trees stay visible zoomed out
const MAX_TREES = 1500
const WOOD_AREA_PER_TREE = 250.0 ## m²
const PARK_AREA_PER_TREE = 1200.0 ## m²

# Light, like the buildings in Home Assistant's map colours
const ROOF_COLOR = Color8(240, 234, 226)
const WALL_COLOR = Color8(214, 205, 194)

## Worker thread entry point; hands the result back to the main thread.
static func task(map_ref: WeakRef, job: Dictionary):
	var result = build(job)
	_deliver.call_deferred(map_ref, result)

static func _deliver(map_ref: WeakRef, result: Dictionary):
	var map = map_ref.get_ref()
	if map != null:
		map._on_built(result)

static func build(job: Dictionary) -> Dictionary:
	var heights = _heights(job)
	var result = {"heights": heights, "view": job.view, "top_left": job.top_left, "zoom": job.zoom, "size": job.size, "ppm": job.ppm}
	var terrain = _terrain_arrays(job.size, heights)
	result.terrain = terrain[0]
	result.sides = terrain[1]
	result.faces = _faces(terrain[0])
	result.buildings = _building_arrays(job, heights) if job.zoom >= BUILDINGS_MIN_ZOOM else null
	var trees = _tree_buffer(job, heights) if job.zoom >= TREES_MIN_ZOOM else [PackedFloat32Array(), 0]
	result.trees = trees[0]
	result.tree_count = trees[1]
	return result

# ---------------------------------------------------------------------------
# Coordinates
# ---------------------------------------------------------------------------

static func _px_size(job: Dictionary) -> Vector2:
	return job.size * job.ppm

## World pixels (at the job's zoom) to ground coordinates: x east, z south.
static func _to_ground(job: Dictionary, world_px: Vector2) -> Vector2:
	return (world_px - job.top_left) / job.ppm - job.size / 2.0

static func _inside(size: Vector2, p: Vector2, margin := 0.0) -> bool:
	return abs(p.x) <= size.x / 2.0 - margin and abs(p.y) <= size.y / 2.0 - margin

## Terrain height (meters of panel) at a ground position, bilinear between the
## grid points of [param heights] (from [method _heights]).
static func height_at(heights: Dictionary, p: Vector2) -> float:
	if heights.is_empty():
		return 0.0
	var nx: int = heights.nx
	var ny: int = heights.ny
	var g = ((p - heights.origin) / heights.cell).clamp(Vector2.ZERO, Vector2(nx - 1, ny - 1) - Vector2(0.001, 0.001))
	var i = int(g.x)
	var j = int(g.y)
	var f = g - Vector2(i, j)
	var values: PackedFloat32Array = heights.values
	var top = lerp(values[j * nx + i], values[j * nx + i + 1], f.x)
	var bottom = lerp(values[(j + 1) * nx + i], values[(j + 1) * nx + i + 1], f.x)
	return lerp(top, bottom, f.y)
# ---------------------------------------------------------------------------
# Terrain
# ---------------------------------------------------------------------------

## Heights from the terrain tiles, read straight from the tile images; flat until
## all of them are loaded (a missing tile would read as 0 m and tear a hole).
##
## The grid points sit at fixed world positions (multiples of the cell size), not at
## fixed spots on the panel: dragging the map moves the hills with it instead of
## sampling them anew under a grid that stays put. The grid reaches one cell past
## the footprint; the mesh cuts it off at the edges.
##
## Returns {values, nx, ny (points per row / column), origin (ground position of
## the first point), cell (ground meters per cell), relief ([lowest m, scale] or null)}.
static func _heights(job: Dictionary) -> Dictionary:
	var px = _px_size(job)
	var cell_px: float = px.x / GRID
	var first = Vector2i(floori(job.top_left.x / cell_px), floori(job.top_left.y / cell_px))
	var last = Vector2i(ceili((job.top_left.x + px.x) / cell_px), ceili((job.top_left.y + px.y) / cell_px))
	var nx = last.x - first.x + 1
	var ny = last.y - first.y + 1
	var heights = {
		"nx": nx, "ny": ny, "cell": Vector2(cell_px, cell_px) / job.ppm, "relief": null,
		"origin": Vector2((first.x * cell_px - job.top_left.x) / job.ppm, (first.y * cell_px - job.top_left.y) / job.ppm) - job.size / 2.0,
	}
	var values = PackedFloat32Array()
	values.resize(nx * ny)
	heights.values = values
	var tiles = job.terrain_tiles
	if tiles == null:
		return heights

	var factor = pow(2.0, job.terrain_zoom - job.zoom)
	var meters = PackedFloat32Array()
	meters.resize(values.size())
	var lowest = INF
	var highest = -INF
	for j in ny:
		for i in nx:
			# World pixel at the terrain zoom
			var p = Vector2((first.x + i) * cell_px * factor, (first.y + j) * cell_px * factor)
			var tile = Vector2i((p / Tiles.TILE_SIZE).floor())
			var image: Image = tiles.get(tile)
			var h = 0.0
			if image != null:
				var local = (p - Vector2(tile) * Tiles.TILE_SIZE).floor().clamp(Vector2.ZERO, Vector2(255, 255))
				var c = image.get_pixel(int(local.x), int(local.y))
				h = (c.r8 * 256.0 + c.g8 + c.b8 / 256.0) - 32768.0
			meters[j * nx + i] = h
			lowest = min(lowest, h)
			highest = max(highest, h)

	var height_scale = job.scale * TERRAIN_EXAGGERATION
	if (highest - lowest) * height_scale > MAX_RELIEF:
		height_scale = MAX_RELIEF / (highest - lowest)
	# While the map is dragged, keep the previous build's base height and relief scale,
	# so the whole terrain doesn't bob up and down with whatever is lowest in view.
	# Start over once the new area doesn't fit them well any more.
	var relief = job.get("relief")
	if relief != null and lowest >= relief[0] - BASE_THICKNESS * 0.5 / relief[1] \
			and (highest - relief[0]) * relief[1] <= MAX_RELIEF * 1.25 and relief[1] >= height_scale * 0.8:
		lowest = relief[0]
		height_scale = relief[1]
	heights.relief = [lowest, height_scale]
	for k in meters.size():
		values[k] = (meters[k] - lowest) * height_scale
	heights.values = values # packed arrays are copied on write; store the filled one
	return heights
## Triangle list of indexed surface arrays, for the terrain's collision shape.
static func _faces(arrays: Array) -> PackedVector3Array:
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var faces = PackedVector3Array()
	faces.resize(indices.size())
	for i in indices.size():
		faces[i] = vertices[indices[i]]
	return faces

## [top surface arrays, side + bottom surface arrays]
static func _terrain_arrays(size: Vector2, heights: Dictionary) -> Array:
	var nx: int = heights.nx
	var ny: int = heights.ny
	var half = size / 2.0
	# Grid points cut off at the footprint; the outer cells are partial.
	var points = []
	for j in ny:
		for i in nx:
			var p = (heights.origin + Vector2(i, j) * heights.cell).clamp(-half, half)
			points.append(Vector3(p.x, height_at(heights, p), p.y))

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for v in points:
		st.set_uv(Vector2(v.x / size.x + 0.5, v.z / size.y + 0.5))
		st.add_vertex(v)
	for j in ny - 1:
		for i in nx - 1:
			var a = j * nx + i
			st.add_index(a); st.add_index(a + 1); st.add_index(a + nx)
			st.add_index(a + 1); st.add_index(a + nx + 1); st.add_index(a + nx)
	var top = st.commit_to_arrays()

	# Sides down to the base, so the terrain reads as a block: around the edge points
	var edge = []
	for i in nx: edge.append(points[i])
	for j in range(1, ny): edge.append(points[j * nx + nx - 1])
	for i in range(nx - 2, -1, -1): edge.append(points[(ny - 1) * nx + i])
	for j in range(ny - 2, 0, -1): edge.append(points[j * nx])
	st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var bottom = Vector3(0, -BASE_THICKNESS, 0)
	for k in edge.size():
		var top_a: Vector3 = edge[k]
		var top_b: Vector3 = edge[(k + 1) % edge.size()]
		var pa = Vector3(top_a.x, 0, top_a.z)
		var pb = Vector3(top_b.x, 0, top_b.z)
		for v in [top_a, top_b, pb + bottom, top_a, pb + bottom, pa + bottom]:
			st.add_vertex(v)
	var corners = [Vector3(-0.5, 0, -0.5), Vector3(0.5, 0, -0.5), Vector3(0.5, 0, 0.5), Vector3(-0.5, 0, 0.5)]
	for k in [0, 1, 2, 0, 2, 3]:
		st.add_vertex(corners[k] * Vector3(size.x, 0, size.y) + bottom)
	return [top, st.commit_to_arrays()]
# ---------------------------------------------------------------------------
# Buildings and trees
# ---------------------------------------------------------------------------

## Ring in tile units -> ground coordinates.
static func _ring_to_ground(job: Dictionary, ring: PackedVector2Array, tx: int, ty: int) -> PackedVector2Array:
	var factor = pow(2.0, job.zoom - Tiles.VECTOR_MAX_ZOOM) * Tiles.TILE_SIZE
	var xform = Transform2D(0.0, Vector2(factor, factor) / job.ppm, 0.0,
		(Vector2(tx, ty) * factor - job.top_left) / job.ppm - job.size / 2.0)
	return xform * ring

## Vector tiles repeat features near their edges (the tile buffer). Keep a polygon
## only in the tile its centre falls in, so nothing is built twice.
static func _owns(ring: PackedVector2Array) -> bool:
	var c = _centroid(ring)
	return c.x >= 0.0 and c.x < 1.0 and c.y >= 0.0 and c.y < 1.0

static func _centroid(ring: PackedVector2Array) -> Vector2:
	var sum = Vector2.ZERO
	for p in ring:
		sum += p
	return sum / max(ring.size(), 1)

static func _building_arrays(job: Dictionary, heights: Dictionary):
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var building_scale = job.scale * BUILDING_EXAGGERATION
	var count = 0

	for tile in job.vector_tiles:
		for building in tile[2].buildings:
			var ring: PackedVector2Array = building[2]
			if not _owns(ring):
				continue
			var outline = _ring_to_ground(job, ring, tile[0], tile[1])
			if not Array(outline).all(func(p): return _inside(job.size, p)):
				continue # cut off at the edge: leave it out rather than overhang
			var roof = Geometry2D.triangulate_polygon(outline)
			if roof.is_empty():
				continue # self-intersecting outline

			var ground = height_at(heights, _centroid(outline))
			var bottom = ground + building[0] * building_scale - (0.001 if building[0] == 0 else 0.0)
			var top = ground + building[1] * building_scale
			var tint = 0.94 + 0.06 * fposmod(sin(outline[0].x * 9137.0 + outline[0].y * 4513.0) * 43758.5, 1.0)

			st.set_color(WALL_COLOR * tint)
			for i in outline.size():
				var a = outline[i]
				var b = outline[(i + 1) % outline.size()]
				for v in [Vector3(a.x, bottom, a.y), Vector3(b.x, bottom, b.y), Vector3(b.x, top, b.y),
						Vector3(a.x, bottom, a.y), Vector3(b.x, top, b.y), Vector3(a.x, top, a.y)]:
					st.add_vertex(v)
			st.set_color(ROOF_COLOR * tint)
			for index in roof:
				st.add_vertex(Vector3(outline[index].x, top, outline[index].y))
			count += 1

	return st.commit_to_arrays() if count > 0 else null

## [MultiMesh buffer (TRANSFORM_3D), instance count]
##
## Trees sit on a fixed world grid: one candidate per grid cell, placed and sized by
## a random generator seeded with the cell. So the same trees come back at the same
## spots in every build, and a dragged map doesn't reshuffle its woods.
static func _tree_buffer(job: Dictionary, heights: Dictionary) -> Array:
	var size: Vector2 = job.size
	var tree_size = max(TREE_HEIGHT * job.scale * BUILDING_EXAGGERATION, MIN_TREE_SIZE)
	var positions = PackedVector2Array()
	var sizes = PackedFloat32Array()
	var rng = RandomNumberGenerator.new()

	# Grid coordinates are in vector tile units (one tile = 1).
	var tile_px = Tiles.TILE_SIZE * pow(2.0, job.zoom - Tiles.VECTOR_MAX_ZOOM) # map px per tile
	var view = Rect2(job.top_left / tile_px, size * job.ppm / tile_px)
	var tile_meters = 40075016.686 / pow(2.0, Tiles.VECTOR_MAX_ZOOM) # at the equator
	# Tiles shrink towards the poles (Mercator); keep fewer candidates to keep the density.
	var keep = pow(cos(deg_to_rad(job.latitude)), 2)

	for kind in [["woods", WOOD_AREA_PER_TREE], ["parks", PARK_AREA_PER_TREE]]:
		var cell = sqrt(kind[1]) / tile_meters
		# Zoomed out, thin the grid (by whole steps, the same everywhere) to bound the work.
		while view.get_area() / (cell * cell) > 4 * MAX_TREES:
			cell *= 2.0
		for tile in job.vector_tiles:
			# Only the tile's own square: its buffer repeats the neighbours' woods.
			var area = Rect2(tile[0], tile[1], 1, 1).intersection(view)
			if area.size.x <= 0 or area.size.y <= 0:
				continue
			for ring: PackedVector2Array in tile[2][kind[0]]:
				if positions.size() >= MAX_TREES:
					break
				var bounds = Rect2(ring[0], Vector2.ZERO)
				for p in ring:
					bounds = bounds.expand(p)
				bounds.position += Vector2(tile[0], tile[1])
				var cells = bounds.intersection(area)
				if cells.size.x <= 0 or cells.size.y <= 0:
					continue
				for cy in range(floori(cells.position.y / cell), ceili(cells.end.y / cell)):
					for cx in range(floori(cells.position.x / cell), ceili(cells.end.x / cell)):
						rng.seed = hash([cx, cy, kind[0], cell])
						if rng.randf() > keep:
							continue
						# Plain floats: world tile coordinates need more precision than Vector2's.
						var gx: float = (cx + rng.randf()) * cell
						var gy: float = (cy + rng.randf()) * cell
						var tree_scale = rng.randf_range(0.75, 1.25)
						if gx < area.position.x or gx >= area.end.x or gy < area.position.y or gy >= area.end.y:
							continue
						if not Geometry2D.is_point_in_polygon(Vector2(gx - tile[0], gy - tile[1]), ring):
							continue
						var p = Vector2((gx * tile_px - job.top_left.x) / job.ppm - size.x / 2.0,
							(gy * tile_px - job.top_left.y) / job.ppm - size.y / 2.0)
						if not _inside(size, p, tree_size / 3.0):
							continue
						positions.append(p)
						sizes.append(tree_scale)
						if positions.size() >= MAX_TREES:
							break
					if positions.size() >= MAX_TREES:
						break

	# MultiMesh TRANSFORM_3D layout: 3 rows of (basis x, basis y, basis z, origin)
	var buffer = PackedFloat32Array()
	buffer.resize(positions.size() * 12)
	for i in positions.size():
		var p = positions[i]
		var s = tree_size * sizes[i]
		var y = height_at(heights, p) + s / 2.0
		var values = [s, 0, 0, p.x, 0, s, 0, y, 0, 0, s, p.y]
		for k in 12:
			buffer[i * 12 + k] = values[k]
	return [buffer, positions.size()]
