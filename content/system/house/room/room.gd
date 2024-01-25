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

func get_corner(index: int) -> MeshInstance3D:
	return wall_corners.get_child(index % wall_corners.get_child_count())

func get_edge(index: int) -> MeshInstance3D:
	return wall_edges.get_child(index % wall_edges.get_child_count())

func has_point(point: Vector3) -> bool:
	return get_aabb().has_point(point)

func remove_corner(index: int):
	get_corner(index).queue_free()
	get_edge(index).queue_free()

func get_aabb():
	if wall_corners.get_child_count() == 0:
		return AABB()

	var min_pos = wall_corners.get_child(0).position
	var max_pos = wall_corners.get_child(0).position

	for corner in wall_corners.get_children():
		min_pos.x = min(min_pos.x, corner.position.x)
		min_pos.z = min(min_pos.z, corner.position.z)

		max_pos.x = max(max_pos.x, corner.position.x)
		max_pos.z = max(max_pos.z, corner.position.z)

	min_pos.y = room_floor.position.y
	max_pos.y = room_ceiling.position.y

	return AABB(to_global(min_pos), to_global(max_pos) - to_global(min_pos))

func update_store():
	var store_room = Store.house.get_room(name)

	var corners = []

	for corner in wall_corners.get_children():
		corners.append(Vector2(corner.position.x, corner.position.z))

	store_room.corners = corners
	store_room.height = room_ceiling.position.y

	Store.house.save_local()
