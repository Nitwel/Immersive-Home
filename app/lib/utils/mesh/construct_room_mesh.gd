static func generate_wall_mesh(corners, height):
	if corners.size() < 3:
		return null

	var st = SurfaceTool.new()
	var wall_up = Vector3.UP * height

	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

	for corner in corners:
		var corner3D = Vector3(corner.x, 0, corner.y)

		st.add_vertex(corner3D + wall_up)
		st.add_vertex(corner3D)

	var first_corner = Vector3(corners[0].x, 0, corners[0].y)

	st.add_vertex(first_corner + wall_up)
	st.add_vertex(first_corner)

	st.index()
	st.generate_normals()
	st.generate_tangents()
	var mesh = st.commit()
	
	return mesh

## Generate a wall mesh with doors
## corners: Array of Vector2
## height: float
## doors: Array[Array[Vector3, Vector3]]
static func generate_wall_mesh_with_doors(corners, height, doors):
	if corners.size() < 3:
		return null

	var mesh = ArrayMesh.new()

	if Geometry2D.is_polygon_clockwise(PackedVector2Array(corners)) == false:
		corners.reverse()

	for i in range(0, corners.size()):
		var corner = corners[i]
		var next_corner = corners[(i + 1) % corners.size()]

		var width = corner.distance_to(next_corner)
		var forward = Vector3(next_corner.x - corner.x, 0, next_corner.y - corner.y).normalized()

		var points := PackedVector2Array()

		points.append(Vector2(0, 0))
		points.append(Vector2(0, height))
		points.append(Vector2(corner.distance_to(next_corner), height))
		points.append(Vector2(corner.distance_to(next_corner), 0))

		for door in doors:
			var door_point1 = Vector2(door[0].x, door[0].z)
			var door_point2 = Vector2(door[1].x, door[1].z)
			var proj_point1 = Geometry2D.get_closest_point_to_segment_uncapped(door_point1, corner, next_corner)
			var proj_point2 = Geometry2D.get_closest_point_to_segment_uncapped(door_point2, corner, next_corner)

			if proj_point1.distance_to(door_point1) > 0.02&&proj_point2.distance_to(door_point2) > 0.02:
				continue

			if proj_point1.distance_to(proj_point2) < 0.02:
				continue

			var point1_distance = corner.distance_to(proj_point1)
			var point2_distance = corner.distance_to(proj_point2)

			var door_points := PackedVector2Array()

			door_points.append(Vector2(point1_distance, -1))
			door_points.append(Vector2(point1_distance, door[0].y))
			door_points.append(Vector2(point2_distance, door[1].y))
			door_points.append(Vector2(point2_distance, -1))

			var clip = Geometry2D.clip_polygons(points, door_points)
			if clip.size() == 0:
				continue

			assert(clip.size() != 2, "Door clip should not create holes")

			points = clip[0]

		var edges = PackedInt32Array()
		for k in range(points.size()):
			edges.append(k)
			edges.append((k + 1) % points.size())

		var cdt: ConstrainedTriangulation = ConstrainedTriangulation.new()
		cdt.init(true, true, 0.1)

		cdt.insert_vertices(points)
		cdt.insert_edges(edges)

		cdt.erase_outer_triangles()

		points = cdt.get_all_vertices()
		var triangles: PackedInt32Array = cdt.get_all_triangles()

		var points_3d = PackedVector3Array()
		var points_uv = PackedVector2Array()

		for k in range(points.size()):
			var point = Vector3(corner.x, 0, corner.y) + points[k].x * forward + Vector3(0, points[k].y, 0)
			points_3d.append(point)
			points_uv.append(Vector2(points[k].x / width, points[k].y / height))

		mesh = _create_mesh_3d(points_3d, triangles, points_uv, width, height, mesh)

	return mesh

static func generate_ceiling_mesh(corners):
	var points: PackedVector2Array = PackedVector2Array()
	var edges: PackedInt32Array = PackedInt32Array()
	var triangles: PackedInt32Array

	if corners.size() < 3:
		return null

	for i in range(corners.size()):
		var corner = corners[i]
		points.append(Vector2(corner.x, corner.y))
		edges.append(i)
		edges.append((i + 1) % corners.size())

	var cdt: ConstrainedTriangulation = ConstrainedTriangulation.new()

	cdt.init(true, true, 0.1)

	cdt.insert_vertices(points)
	cdt.insert_edges(edges)

	cdt.erase_outer_triangles()

	points = cdt.get_all_vertices()
	triangles = cdt.get_all_triangles()

	return _create_mesh_2d(points, triangles)

static func generate_wall_mesh_with_doors_grid(corners, height, doors, grid:=0.1):
	if corners.size() < 3:
		return null

	var mesh = ArrayMesh.new()

	for i in range(0, corners.size()):
		var corner = corners[i]
		var next_corner = corners[(i + 1) % corners.size()]

		var width = corner.distance_to(next_corner)
		var forward = Vector3(next_corner.x - corner.x, 0, next_corner.y - corner.y).normalized()

		var points := PackedVector2Array()

		points.append(Vector2(0, 0))
		points.append(Vector2(0, height))
		points.append(Vector2(corner.distance_to(next_corner), height))
		points.append(Vector2(corner.distance_to(next_corner), 0))

		for door in doors:
			var door_point1 = Vector2(door[0].x, door[0].z)
			var door_point2 = Vector2(door[1].x, door[1].z)
			var proj_point1 = Geometry2D.get_closest_point_to_segment_uncapped(door_point1, corner, next_corner)
			var proj_point2 = Geometry2D.get_closest_point_to_segment_uncapped(door_point2, corner, next_corner)

			if proj_point1.distance_to(door_point1) > 0.02&&proj_point2.distance_to(door_point2) > 0.02:
				continue

			if proj_point1.distance_to(proj_point2) < 0.02:
				continue

			var point1_distance = corner.distance_to(proj_point1)
			var point2_distance = corner.distance_to(proj_point2)

			var door_points := PackedVector2Array()

			door_points.append(Vector2(point1_distance, -1))
			door_points.append(Vector2(point1_distance, door[0].y))
			door_points.append(Vector2(point2_distance, door[1].y))
			door_points.append(Vector2(point2_distance, -1))

			var clip = Geometry2D.clip_polygons(points, door_points)
			if clip.size() == 0:
				continue

			assert(clip.size() != 2, "Door clip should not create holes")

			points = clip[0]

		# Subdivide edge to grid

		var new_points = PackedVector2Array()

		for k in range(points.size()):
			var point = points[k]
			var next_point = points[(k + 1) % points.size()]

			new_points.append(point)
			
			var steps = floor(point.distance_to(next_point) / grid)

			for x in range(1, steps):
				new_points.append(point + (next_point - point).normalized() * grid * x)

		points = new_points

		var edges = PackedInt32Array()
		for k in range(points.size()):
			edges.append(k)
			edges.append((k + 1) % points.size())

		# Subdivide inner polygon to grid
		var steps = ceil(Vector2(corner.distance_to(next_corner) / grid, height / grid))

		for y in range(1, steps.y):
			for x in range(1, steps.x):
				var point = Vector2(x * grid, y * grid)

				points.append(point)

		var cdt: ConstrainedTriangulation = ConstrainedTriangulation.new()
		cdt.init(true, true, 0.001)

		cdt.insert_vertices(points)
		cdt.insert_edges(edges)

		cdt.erase_outer_triangles()

		points = cdt.get_all_vertices()
		var triangles: PackedInt32Array = cdt.get_all_triangles()

		var points_3d = PackedVector3Array()
		var points_uv = PackedVector2Array()

		for k in range(points.size()):
			points_3d.append(Vector3(corner.x, 0, corner.y) + points[k].x * forward + Vector3(0, points[k].y, 0))
			points_uv.append(Vector2(points[k].x / width, points[k].y / height))

		mesh = _create_mesh_3d(points_3d, triangles, points_uv, width, height, mesh)

	return mesh

static func generate_wall_mesh_grid(corners, height, grid: Vector2=Vector2(0.1, 0.1)):
	if corners.size() < 3:
		return null

	var st = SurfaceTool.new()

	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for corner_i in range(corners.size()):
		var corner = Vector3(corners[corner_i].x, 0, corners[corner_i].y)
		var next_index = (corner_i + 1) % corners.size()
		var next_corner = Vector3(corners[next_index].x, 0, corners[next_index].y)

		var steps = ceil(Vector2((next_corner - corner).length() / grid.x, height / grid.y))

		var forward_dir = (next_corner - corner).normalized() * grid.x
		var up_dir = Vector3.UP * grid.y

		var close_distance = Vector2(1, 1)

		for y in range(0, steps.y):

			close_distance.x = 1

			if y == steps.y - 1:
					close_distance.y = fmod(height, grid.y) / grid.y

			for x in range(0, steps.x):
				var point = corner + forward_dir * x + Vector3.UP * grid.y * y

				if x == steps.x - 1:
					close_distance.x = fmod(corner.distance_to(next_corner), grid.x) / grid.x
				
				st.add_vertex(point)
				st.add_vertex(point + forward_dir * close_distance.x)
				st.add_vertex(point + up_dir * close_distance.y)

				st.add_vertex(point + forward_dir * close_distance.x)
				st.add_vertex(point + forward_dir * close_distance.x + up_dir * close_distance.y)
				st.add_vertex(point + up_dir * close_distance.y)

	st.index()
	st.generate_normals()
	st.generate_tangents()
	var mesh = st.commit()
	
	return mesh

static func generate_ceiling_mesh_grid(corners, grid: Vector2=Vector2(0.1, 0.1)):
	var points: PackedVector2Array = PackedVector2Array()
	var edges: PackedInt32Array = PackedInt32Array()
	var triangles: PackedInt32Array

	if corners.size() < 3:
		return null

	var min_val = Vector2(corners[0])
	var max_val = Vector2(corners[0])

	for i in range(corners.size()):
		var corner = corners[i]

		min_val.x = min(min_val.x, corner.x)
		min_val.y = min(min_val.y, corner.y)
		max_val.x = max(max_val.x, corner.x)
		max_val.y = max(max_val.y, corner.y)

		points.append(Vector2(corner.x, corner.y))
		edges.append(i)
		edges.append((i + 1) % corners.size())

	var size = max_val - min_val

	# Subdivide edges to grid
	for i in range(corners.size()):
		var corner = corners[i]
		var next_index = (i + 1) % corners.size()
		var next_corner = corners[next_index]

		var steps = ceil(Vector2((next_corner - corner).length() / grid.x, size.y / grid.y))

		var forward_dir = (next_corner - corner).normalized() * grid.x

		for x in range(1, steps.x):
			var point = corner + forward_dir * x

			points.append(Vector2(point.x, point.y))

	## Fill points insde the polygon
	for y in range(1, int(size.y / grid.y)):
		var x_intersections: Array[float] = []

		var y_start = Vector2(min_val.x, min_val.y + y * grid.y)
		var y_end = Vector2(max_val.x, min_val.y + y * grid.y)

		for i in range(corners.size()):
			var a = corners[i]
			var b = corners[(i + 1) % corners.size()]

			var result = Geometry2D.segment_intersects_segment(a, b, y_start, y_end)

			if result != null:
				x_intersections.append(result.x)

		var intersection_counter = 0

		x_intersections.sort()

		for x in range(1, int(size.x / grid.x)):
			var point = min_val + Vector2(x * grid.x, y * grid.y)

			for i in range(intersection_counter, x_intersections.size()):
				if x_intersections[i] < point.x:
					intersection_counter += 1

			var color = Color(1, 1, 0)

			if intersection_counter % 2 == 1:
				color = Color(1, 0, 1)
				points.append(point)

	var cdt: ConstrainedTriangulation = ConstrainedTriangulation.new()

	cdt.init(true, true, 0.1)

	cdt.insert_vertices(points)
	cdt.insert_edges(edges)

	cdt.erase_outer_triangles()

	points = cdt.get_all_vertices()
	triangles = cdt.get_all_triangles()

	return _create_mesh_2d(points, triangles)

static func _create_mesh_3d(points: PackedVector3Array, triangles: PackedInt32Array, points_uv, width: float, height: float, existing=null):
	var st = SurfaceTool.new()

	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_custom_format(0, SurfaceTool.CUSTOM_RG_FLOAT)

	for i in range(points.size()):
		st.set_uv(points_uv[i])
		st.set_custom(0, Color(width, height, 0, 0))
		st.add_vertex(Vector3(points[i].x, points[i].y, points[i].z))

	for i in range(triangles.size()):
		st.add_index(triangles[i])

	st.index()
	st.generate_normals()
	st.generate_tangents()

	if existing != null:
		return st.commit(existing)

	return st.commit()

static func _create_mesh_2d(points: PackedVector2Array, triangles: PackedInt32Array):
	var st = SurfaceTool.new()

	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_custom_format(0, SurfaceTool.CUSTOM_RG_FLOAT)

	for i in range(points.size()):
		st.set_uv(Vector2(0.5, 0.5))
		st.set_custom(0, Color(1.0, 1.0, 0, 0))
		st.add_vertex(Vector3(points[i].x, 0, points[i].y))

	for i in range(triangles.size()):
		st.add_index(triangles[i])

	st.index()
	st.generate_normals()
	st.generate_tangents()

	var mesh = st.commit()

	return mesh
