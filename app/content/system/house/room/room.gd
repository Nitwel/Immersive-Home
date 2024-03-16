extends Node3D

@onready var wall_corners = $Ceiling/WallCorners
@onready var wall_edges = $Ceiling/WallEdges
@onready var wall_mesh: MeshInstance3D = $WallMesh
@onready var ceiling_mesh: MeshInstance3D = $CeilingMesh
@onready var wall_collisions = $WallCollisions

@onready var room_floor = $Floor
@onready var room_ceiling = $Ceiling

@onready var state_machine = $StateMachine

var editable: bool = false:
	set(value):
		if !is_node_ready(): await ready

		if value:
			state_machine.change_to("Edit")
		else:
			state_machine.change_to("View")

func has_point(point: Vector3) -> bool:
	return get_aabb().has_point(point)

func get_aabb():
	var room_store = Store.house.get_room(name)

	if room_store == null:
		return AABB()

	var corners = room_store.corners

	if corners.size() == 0:
		return AABB()

	var min_pos = Vector3(corners[0].x, 0, corners[0].y)
	var max_pos = min_pos

	for corner in corners:
		min_pos.x = min(min_pos.x, corner.x)
		min_pos.z = min(min_pos.z, corner.y)

		max_pos.x = max(max_pos.x, corner.x)
		max_pos.z = max(max_pos.z, corner.y)

	min_pos.y = 0
	max_pos.y = room_store.height

	return AABB(to_global(min_pos), to_global(max_pos) - to_global(min_pos))

static func generate_wall_mesh(room_store: Dictionary):
	if room_store.corners.size() < 2:
		return null

	var st = SurfaceTool.new()
	var wall_up = Vector3.UP * room_store.height

	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

	for corner in room_store.corners:
		var corner3D = Vector3(corner.x, 0, corner.y)

		st.add_vertex(corner3D)
		st.add_vertex(corner3D + wall_up)

	var first_corner = Vector3(room_store.corners[0].x, 0, room_store.corners[0].y)

	st.add_vertex(first_corner)
	st.add_vertex(first_corner + wall_up)

	st.index()
	st.generate_normals()
	st.generate_tangents()
	var mesh = st.commit()
	
	return mesh

static func generate_ceiling_mesh(room_store: Dictionary):

	var points: PackedVector2Array = PackedVector2Array()
	var edges: PackedInt32Array = PackedInt32Array()
	var triangles: PackedInt32Array

	var corners = room_store.corners

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
