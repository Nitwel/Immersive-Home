extends RoomState

const RoomState = preload ("./room_state.gd")

func _on_enter():
	var room_store = Store.house.get_room(room.name)

	if room_store == null:
		return

	room.wall_mesh.mesh = room.generate_wall_mesh()

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

	var wall_collisions = room.wall_mesh.mesh.create_trimesh_shape()
	wall_collisions.backface_collision = true
	room.wall_collision.shape = wall_collisions

func _on_leave():
	room.room_ceiling.get_node("CollisionShape3D").disabled = true
	room.room_floor.get_node("CollisionShape3D").disabled = true

	room.wall_collision.shape = null
	room.wall_mesh.mesh = null
	room.ceiling_mesh.mesh = null