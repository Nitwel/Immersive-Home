extends RoomState

const RoomState = preload("./room_state.gd")


func _on_enter():
	var room_store = Store.house.get_room(room.name)

	if room_store == null || room_store.corners.size() < 3:
		return

	room.wall_mesh.visible = false
	room.ceiling_mesh.visible = false

	room.wall_mesh.mesh = Room.generate_wall_mesh(room_store)

	if room.wall_mesh.mesh == null:
		return

	var ceiling_shape = room.room_ceiling.get_node("CollisionShape3D")
	var floor_shape = room.room_floor.get_node("CollisionShape3D")

	ceiling_shape.disabled = false
	floor_shape.disabled = false

	room.ceiling_mesh.mesh = Room.generate_ceiling_mesh(room_store)
	ceiling_shape.shape = room.ceiling_mesh.mesh.create_trimesh_shape()
	floor_shape.shape = room.ceiling_mesh.mesh.create_trimesh_shape()
	ceiling_shape.shape.backface_collision = true
		
	var collisions = generate_collision()

	for collision in collisions:
		var static_body = StaticBody3D.new()
		static_body.set_collision_layer_value(4, true)
		static_body.set_collision_layer_value(5, true)
		static_body.collision_mask = 0
		static_body.add_child(collision)
		room.wall_collisions.add_child(static_body)

func _on_leave():
	room.room_ceiling.get_node("CollisionShape3D").disabled = true
	room.room_floor.get_node("CollisionShape3D").disabled = true

	for collision in room.wall_collisions.get_children():
		collision.queue_free()
		await collision.tree_exited

func generate_collision():
	var room_store = Store.house.get_room(room.name)

	var collision_shapes: Array[CollisionShape3D] = []

	var corners = room_store.corners

	for i in range(corners.size()):
		var corner = Vector3(corners[i].x, 0, corners[i].y)
		var next_corner_index = (i + 1) % corners.size()
		var next_corner = Vector3(corners[next_corner_index].x, 0, corners[next_corner_index].y)

		var shape = BoxShape3D.new()
		shape.size = Vector3((next_corner - corner).length(), room_store.height, 0.04)

		var transform = Transform3D()
		var back_vector = (corner - next_corner).cross(Vector3.UP).normalized() * shape.size.z / 2

		transform.basis = Basis((next_corner - corner).normalized(), Vector3.UP,  back_vector.normalized())
		transform.origin = corner + (next_corner - corner) / 2 + back_vector + Vector3.UP * shape.size.y / 2

		var collision_shape = CollisionShape3D.new()

		collision_shape.shape = shape
		collision_shape.transform = transform

		collision_shapes.append(collision_shape)
	
	return collision_shapes
