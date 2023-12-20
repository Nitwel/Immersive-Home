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
	return wall_mesh.get_aabb().has_point(point)

func _save():
	return {
		"corners": wall_corners.get_children().map(func(corner): return corner.position),
		"name": name
	}

func _load(data):
	await ready
	return

	name = data["name"]

	state_machine.change_to("Edit")

	for corner in data["corners"]:
		state_machine.current_state.add_corner(corner)

	state_machine.change_to("View")
