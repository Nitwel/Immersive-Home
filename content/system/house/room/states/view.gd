extends RoomState

const RoomState = preload("./room_state.gd")

var room_height = 3
var corner_count = 0

func _on_enter():
	corner_count = room.wall_corners.get_child_count()

	if corner_count < 3:
		return

	room_height = room.get_corner(0).global_position.y

	room.wall_mesh.visible = true
	room.ceiling_mesh.visible = true
	room.wall_mesh.mesh = generate_mesh()

	if room.wall_mesh.mesh == null:
		return

	room.ceiling_mesh.mesh = generate_ceiling_mesh()
	room.room_ceiling.get_node("CollisionShape3D").shape = room.ceiling_mesh.mesh.create_trimesh_shape()
	room.room_floor.get_node("CollisionShape3D").shape = room.ceiling_mesh.mesh.create_trimesh_shape()
	room.room_ceiling.get_node("CollisionShape3D").shape.backface_collision = true
		
	var collisions = generate_collision()

	for collision in collisions:
		var static_body = StaticBody3D.new()
		static_body.set_collision_layer_value(4, true)
		static_body.set_collision_layer_value(5, true)
		static_body.collision_mask = 0
		static_body.add_child(collision)
		room.wall_collisions.add_child(static_body)
	
	room.wall_mesh.visible = true

func _on_leave():
	room.wall_mesh.visible = false
	room.ceiling_mesh.visible = false

	for collision in room.wall_collisions.get_children():
		collision.queue_free()

func generate_mesh():
	var st = SurfaceTool.new()
	var wall_up = Vector3.UP * room_height

	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

	for i in range(corner_count):
		var corner = room.get_corner(i)

		st.add_vertex(corner.position)
		st.add_vertex(corner.position + wall_up)

	var first_corner = room.get_corner(0)

	st.add_vertex(first_corner.position)
	st.add_vertex(first_corner.position + wall_up)

	st.index()
	st.generate_normals()
	st.generate_tangents()
	var mesh = st.commit()
	
	return mesh

func generate_ceiling_mesh():
	var points: PackedVector2Array = PackedVector2Array()
	var edges: PackedInt32Array = PackedInt32Array()
	var triangles: PackedInt32Array

	for i in range(corner_count):
		var corner = room.get_corner(i)
		points.append(Vector2(corner.position.x, corner.position.z))
		edges.append(i)
		edges.append((i + 1) % corner_count)

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

func generate_collision():
	var collision_shapes: Array[CollisionShape3D] = []

	for i in range(corner_count):
		var corner = room.get_corner(i)
		var next_corner = room.get_corner(i + 1)

		var shape = BoxShape3D.new()
		shape.size = Vector3((next_corner.position - corner.position).length(), room_height, 0.04)

		var transform = Transform3D()
		var back_vector = (corner.position - next_corner.position).cross(Vector3.UP).normalized() * shape.size.z / 2

		transform.basis = Basis((next_corner.position - corner.position).normalized(), Vector3.UP,  back_vector.normalized())
		transform.origin = corner.position + (next_corner.position - corner.position) / 2 + back_vector + Vector3.UP * shape.size.y / 2

		var collision_shape = CollisionShape3D.new()

		collision_shape.shape = shape
		collision_shape.transform = transform

		collision_shapes.append(collision_shape)
	
	return collision_shapes