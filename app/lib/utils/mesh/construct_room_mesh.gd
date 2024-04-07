static func generate_wall_mesh(corners, height):
	if corners.size() < 3:
		return null

	var st = SurfaceTool.new()
	var wall_up = Vector3.UP * height

	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

	for corner in corners:
		var corner3D = Vector3(corner.x, 0, corner.y)

		st.add_vertex(corner3D)
		st.add_vertex(corner3D + wall_up)

	var first_corner = Vector3(corners[0].x, 0, corners[0].y)

	st.add_vertex(first_corner)
	st.add_vertex(first_corner + wall_up)

	st.index()
	st.generate_normals()
	st.generate_tangents()
	var mesh = st.commit()
	
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

	return _create_mesh(points, triangles)

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
					print(close_distance.y)

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

	return _create_mesh(points, triangles)

static func _create_mesh(points: PackedVector2Array, triangles: PackedInt32Array):
	var st = SurfaceTool.new()

	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in range(points.size()):
		st.add_vertex(Vector3(points[i].x, 0, points[i].y))

	for i in range(triangles.size()):
		st.add_index(triangles[i])

	st.index()
	st.generate_normals()
	st.generate_tangents()

	var mesh = st.commit()

	return mesh