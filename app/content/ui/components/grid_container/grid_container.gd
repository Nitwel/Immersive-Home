@tool
extends Container3D
class_name GridContainer3D

@export var columns := 5:
	set(value):
		columns = value
		_update()

@export var gaps := Vector2(0, 0):
	set(value):
		gaps = value
		_update()

func _ready():
	_update()

	child_entered_tree.connect(func(_arg):
		_update()
	)

	child_exiting_tree.connect(func(_arg):
		_update()
	)

	child_order_changed.connect(func():
		_update()
	)

func _update():
	var column := 0
	var row_pos := 0.0
	var column_max_height := 0.0

	for child in get_children():
		if child is Container3D == false:
			continue

		column_max_height = max(column_max_height, child.size.y)

		child.position = Vector3(column * ((size.x / columns) + gaps.x), row_pos, 0)

		column += 1
		if column >= columns:
			column = 0
			row_pos -= column_max_height + gaps.y
		