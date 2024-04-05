extends RoomState

const RoomState = preload ("./room_state.gd")

func _on_enter():
	var room_store = Store.house.get_room(room.name)

	if room_store == null||room_store.corners.size() < 3:
		return

	room.wall_mesh.visible = false
	room.ceiling_mesh.visible = false

	room.wall_mesh.mesh = Room.generate_wall_mesh(room_store)

	if room.wall_mesh.mesh == null:
		return

	room.room_ceiling.position.y = room_store.height

	var ceiling_shape = room.room_ceiling.get_node("CollisionShape3D")
	var floor_shape = room.room_floor.get_node("CollisionShape3D")

	ceiling_shape.disabled = false
	floor_shape.disabled = false

	room.ceiling_mesh.mesh = Room.generate_ceiling_mesh(room_store)
	ceiling_shape.shape = room.ceiling_mesh.mesh.create_trimesh_shape()
	floor_shape.shape = room.ceiling_mesh.mesh.create_trimesh_shape()
	ceiling_shape.shape.backface_collision = true

	var collision = CollisionShape3D.new()
	collision.shape = room.wall_mesh.mesh.create_trimesh_shape()
		
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
