extends RoomState

const RoomState = preload("./room_state.gd")
const walls_mini_material = preload("../walls_mini.tres")
const walls_material = preload("../walls.tres")

func _on_enter():
	room.wall_mesh.visible = true
	room.ceiling_mesh.visible = true
	room.wall_mesh.material_override = walls_mini_material
	room.room_ceiling.get_node("CollisionShape3D").disabled = true
	room.room_floor.get_node("CollisionShape3D").disabled = true

	for collision in room.wall_collisions.get_children():
		collision.get_child(0).disabled = true

	for corner in room.wall_corners.get_children():
		corner.get_node("CollisionShape3D").disabled = true

	for edge in room.wall_edges.get_children():
		edge.get_node("CollisionShape3D").disabled = true
		
	

func _on_leave():
	room.wall_mesh.visible = false
	room.ceiling_mesh.visible = false
	room.wall_mesh.material_override = walls_material
	room.room_ceiling.get_node("CollisionShape3D").disabled = false
	room.room_floor.get_node("CollisionShape3D").disabled = false

	for collision in room.wall_collisions.get_children():
		collision.get_child(0).disabled = false
	
	for corner in room.wall_corners.get_children():
		corner.get_node("CollisionShape3D").disabled = false

	for edge in room.wall_edges.get_children():
		edge.get_node("CollisionShape3D").disabled = false

	
