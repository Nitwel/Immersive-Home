## Generate a door mesh between two rooms based on their upper left and right corners
static func generate_door_mesh(room1_pos1: Vector3, room2_pos1: Vector3, room2_pos2: Vector3, room1_pos2: Vector3):
	var st = SurfaceTool.new()

	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_custom_format(0, SurfaceTool.CUSTOM_RG_FLOAT)

	var points = [room1_pos1, room2_pos1, room2_pos2, room1_pos2, Vector3(room1_pos1.x, 0, room1_pos1.z), Vector3(room2_pos1.x, 0, room2_pos1.z), Vector3(room2_pos2.x, 0, room2_pos2.z), Vector3(room1_pos2.x, 0, room1_pos2.z)]

	# Add top face
	add_quad(st, points, 0, 1, 2, 3)

	# Add bottom face
	add_quad(st, points, 5, 4, 7, 6)

	# Add side faces
	add_quad(st, points, 0, 4, 5, 1)
	add_quad(st, points, 2, 6, 7, 3)

	st.deindex()
	st.generate_normals()
	st.generate_tangents()

	return st.commit()

static func generate_door_mesh_grid(room1_pos1: Vector3, room2_pos1: Vector3, room2_pos2: Vector3, room1_pos2: Vector3, grid:=0.1):
	var st = SurfaceTool.new()

	var room1_pos1_bottom = Vector3(room1_pos1.x, 0, room1_pos1.z)
	var room2_pos1_bottom = Vector3(room2_pos1.x, 0, room2_pos1.z)
	var room2_pos2_bottom = Vector3(room2_pos2.x, 0, room2_pos2.z)
	var room1_pos2_bottom = Vector3(room1_pos2.x, 0, room1_pos2.z)

	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_custom_format(0, SurfaceTool.CUSTOM_RG_FLOAT)

	# Add top
	add_quad_grid(st, room1_pos1, room1_pos2, room2_pos2, room2_pos1, false, grid)

	# Add bottom
	add_quad_grid(st, room1_pos1_bottom, room1_pos2_bottom, room2_pos2_bottom, room2_pos1_bottom, true, grid)

	# Add side faces
	add_quad_grid(st, room1_pos1, room1_pos1_bottom, room2_pos1_bottom, room2_pos1, true, grid)
	add_quad_grid(st, room1_pos2, room1_pos2_bottom, room2_pos2_bottom, room2_pos2, false, grid)

	st.deindex()
	st.generate_normals()
	st.generate_tangents()

	return st.commit()

static func add_quad(st: SurfaceTool, points, index1: int, index2: int, index3: int, index4: int):
	st.set_uv(Vector2(0.0, 0.0))
	st.set_custom(0, Color(2.0, 2.0, 0, 0))
	st.add_vertex(points[index1])

	st.set_uv(Vector2(1.0, 1.0))
	st.set_custom(0, Color(2.0, 2.0, 0, 0))
	st.add_vertex(points[index3])

	st.set_uv(Vector2(1.0, 0.0))
	st.set_custom(0, Color(2.0, 2.0, 0, 0))
	st.add_vertex(points[index2])

	st.set_uv(Vector2(0.0, 0.0))
	st.set_custom(0, Color(2.0, 2.0, 0, 0))
	st.add_vertex(points[index1])

	st.set_uv(Vector2(0.0, 1.0))
	st.set_custom(0, Color(2.0, 2.0, 0, 0))
	st.add_vertex(points[index4])

	st.set_uv(Vector2(1.0, 1.0))
	st.set_custom(0, Color(2.0, 2.0, 0, 0))
	st.add_vertex(points[index3])

static func add_quad_grid(st: SurfaceTool, p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3, flipped: bool=false, grid:=1.0):
	var d1 = (p2 - p1).normalized()
	var d2 = (p4 - p1).normalized()

	var n1 = d1.cross(d2).normalized()

	var transform_local = Transform3D(d1, n1, d2, p1)

	var lp1 = transform_local.affine_inverse() * p1
	var lp2 = transform_local.affine_inverse() * p2
	var lp3 = transform_local.affine_inverse() * p3
	var lp4 = transform_local.affine_inverse() * p4

	lp1 = Vector2(lp1.x, lp1.z)
	lp2 = Vector2(lp2.x, lp2.z)
	lp3 = Vector2(lp3.x, lp3.z)
	lp4 = Vector2(lp4.x, lp4.z)

	var points = PackedVector2Array()

	# Generate edges
	var edge_points = [lp1, lp2, lp3, lp4]

	for i in range(4):
		var delta: Vector2 = edge_points[(i + 1) % 4] - edge_points[i]

		var steps = ceil(delta.length() / grid)

		for j in range(steps):
			var p = edge_points[i] + delta.normalized() * j * grid
			points.push_back(p)

	var edges = PackedInt32Array()
	
	for k in range(points.size()):
		edges.append(k)
		edges.append((k + 1) % points.size())

	# Generate points
	var rect = Rect2()
	rect = rect.expand(lp1)
	rect = rect.expand(lp2)
	rect = rect.expand(lp3)
	rect = rect.expand(lp4)

	var ls = rect.position
	var ld1 = rect.size.x
	var ld2 = rect.size.y

	var steps = Vector2(ld1 / grid, ld2 / grid).ceil() + Vector2(2, 2)

	for i in range(steps.x):
		for j in range(steps.y):
			var p = Vector2(i, j) * grid + ls - Vector2(0.5, 0.5) * grid
			points.push_back(p)

	# Triangulate
	var cdt: ConstrainedTriangulation = ConstrainedTriangulation.new()
	cdt.init(true, true, 0.01)

	cdt.insert_vertices(points)
	cdt.insert_edges(edges)

	cdt.erase_outer_triangles()

	points = cdt.get_all_vertices()
	var triangles: PackedInt32Array = cdt.get_all_triangles()

	var points3D = PackedVector3Array()

	for i in range(points.size()):
		var pos3D = transform_local * Vector3(points[i].x, 0, points[i].y)

		points3D.push_back(pos3D)

	if flipped:
		for i in range(triangles.size() / 3):
			var temp = triangles[i * 3]
			triangles[i * 3] = triangles[i * 3 + 1]
			triangles[i * 3 + 1] = temp

	for i in range(triangles.size()):
		st.set_uv(Vector2(0.5, 0.5))
		st.set_custom(0, Color(1.0, 1.0, 0, 0))
		st.add_vertex(points3D[triangles[i]])
			