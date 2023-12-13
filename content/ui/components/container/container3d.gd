extends Node3D
class_name Container3D

@export var size := Vector3(1.0, 1.0, 1.0) :
	set(value):
		size = value
		_update_container()

@export var padding: Vector4 = Vector4(0, 0, 0, 0) :
	set(value):
		padding = value
		_update_container()

func _update_container():
	pass