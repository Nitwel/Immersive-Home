@tool

extends Node3D
class_name Container3D

@export var size := Vector3(1.0, 1.0, 1.0):
	set(value):
		size = Vector3(max(0, value.x), max(0, value.y), max(0, value.z))

		if !is_inside_tree(): return

		_update()

func _ready():
	_update()

func _update():
	pass