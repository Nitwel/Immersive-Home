@tool
extends Function
class_name Movable

var hit_node := Node3D.new()

func _on_grab_down(event):
	event.controller.add_child(hit_node)
	hit_node.global_position = get_parent().global_position

func _on_grab_move(event):
	get_parent().global_position = hit_node.global_position
	get_parent().global_rotation = hit_node.global_rotation

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	if get_parent() is StaticBody3D == false:
		warnings.append("Movable requires a StaticBody3D as parent.")
	

	return warnings
