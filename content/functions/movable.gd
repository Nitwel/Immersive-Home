@tool
extends Function
class_name Movable

var start_pos:Vector3
var start_rot:Vector3

var grab_pos:Vector3
var grab_rot:Vector3

func _on_grab_down(event):
	print("grab down movable")
	start_pos = get_parent().position
	start_rot = get_parent().rotation

	grab_pos = event.controller.position
	grab_rot = event.controller.rotation


func _on_grab_move(event):
	print("grab move movable")
	var delta_pos = event.controller.position - grab_pos
	var delta_rot = event.controller.rotation - grab_rot

	print(delta_pos, delta_rot)

	get_parent().position = start_pos + delta_pos
	get_parent().rotation = start_rot + delta_rot

func _on_grab_up(event):
	print("grab up movable")

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	if get_parent() is StaticBody3D == false:
		warnings.append("Movable requires a StaticBody3D as parent.")
	

	return warnings