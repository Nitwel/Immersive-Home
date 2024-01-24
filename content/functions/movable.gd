@tool
extends Function
class_name Movable

signal on_move(position: Vector3, rotation: Vector3)

@export var restricted: bool = false
@export var restrict_movement: Callable
@export var lock_rotation: bool = false
var hit_node := Node3D.new()

func _on_grab_down(event: EventPointer):
	if restricted && event.target != get_parent():
		return

	event.initiator.node.add_child(hit_node)
	hit_node.global_transform = get_parent().global_transform

func _on_grab_move(_event: EventPointer):
	if hit_node.get_parent() == null:
		return
	
	if restrict_movement:
		get_parent().global_position = restrict_movement.call(hit_node.global_position)
	else:
		get_parent().global_position = hit_node.global_position

	if !lock_rotation:
		get_parent().global_rotation = hit_node.global_rotation
		on_move.emit(get_parent().global_position, get_parent().global_rotation)
	else:
		on_move.emit(get_parent().global_position, Vector3(0, 0, 0))


func _on_grab_up(event: EventPointer):
	event.initiator.node.remove_child(hit_node)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	if get_parent() is StaticBody3D == false:
		warnings.append("Movable requires a StaticBody3D as parent.")
	

	return warnings
