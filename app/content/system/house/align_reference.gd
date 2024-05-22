extends Node3D

@onready var corner1 = $Corner1
@onready var corner2 = $Corner1/Corner2
@onready var edge = $Edge
@onready var marker = $Edge/Marker3D

@export var disabled: bool:
	set(value):
		disabled = value

		if !is_inside_tree(): return
		
		corner1.get_node("CollisionShape3D").disabled = disabled
		corner2.get_node("CollisionShape3D").disabled = disabled
		edge.get_node("CollisionShape3D").disabled = disabled
		corner1.visible = !disabled
		corner2.visible = !disabled
		edge.visible = !disabled

func _ready():
	update_initial_positions.call_deferred()

	corner1.get_node("Movable").on_move.connect(func(position, rotation):
		edge.align_to_corners(corner1.global_position, corner2.global_position)
	)

	corner2.get_node("Movable").on_move.connect(func(position, rotation):
		edge.align_to_corners(corner1.global_position, corner2.global_position)

		corner2.look_at(corner1.global_position, Vector3.UP)
		corner2.rotate(Vector3.UP, deg_to_rad( - 90))
	)

	corner2.get_node("Movable").restrict_movement = func(new_position):
		new_position.y = corner1.global_position.y

		var delta_new_pos_corner1 = (new_position - corner1.position).normalized()

		return corner1.position + delta_new_pos_corner1

func update_initial_positions():
	if App.main.is_node_ready() == false:
		await App.main.ready

	edge.align_to_corners(corner1.global_position, corner2.global_position)
	marker.global_transform = App.house.transform

func get_new_transform():
	marker.scale = Vector3(1, 1, 1)
	return marker.global_transform

func update_align_reference():
	corner1.global_position = Store.house.state.align_position1
	corner2.global_position = Store.house.state.align_position2
	
	if corner1.global_position == corner2.global_position:
		corner2.global_position = corner1.global_position + Vector3(1, 0, 0)

	corner2.look_at(corner1.global_position, Vector3.UP)
	corner2.rotate(Vector3.UP, deg_to_rad( - 90))

	edge.align_to_corners(corner1.global_position, corner2.global_position)

func update_store():
	Store.house.state.align_position1 = corner1.global_position
	Store.house.state.align_position2 = corner2.global_position
