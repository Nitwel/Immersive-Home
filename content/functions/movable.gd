@tool
extends Function
class_name Movable

@export var restricted: bool = false
@export var lock_rotation: bool = false
var hit_node := Node3D.new()

func _on_grab_down(event: EventPointer):
	if restricted && event.target != get_parent():
		return

	event.initiator.node.add_child(hit_node)
	hit_node.global_transform = get_parent().global_transform

func _on_grab_move(_event: EventPointer):
	get_parent().global_position = hit_node.global_position

	if !lock_rotation:
		get_parent().global_rotation = hit_node.global_rotation

func _on_grab_up(event: EventPointer):
	event.initiator.node.remove_child(hit_node)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	if get_parent() is StaticBody3D == false:
		warnings.append("Movable requires a StaticBody3D as parent.")
	

	return warnings
