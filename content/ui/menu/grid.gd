@tool
extends Container3D
class_name GridContainer3D


@export var columns := 5 :
	set(value):
		columns = value
		_update_container()

@export var rows := 1 :
	set(value):
		rows = value
		_update_container()

@export var depth_gap := 1.0 :
	set(value):
		depth_gap = value
		_update_container()

func _ready():
	_update_container()

func get_gaps() -> Vector3:
	return Vector3(
		(float(size.x) / (columns - 1 )) if columns != 1 else 0.0,
		(float(size.y) / (rows - 1)) if rows != 1 else 0.0,
		depth_gap
	)


func _update_container():
	var i := 0
	var gaps := get_gaps()

	for child in get_children():
		var x := (i % columns) * gaps.x
		var y := ((i / columns) % rows) * gaps.y
		var z := (i / (columns * rows)) * gaps.z

		child.set_position(Vector3(x, -y, z))
		i += 1