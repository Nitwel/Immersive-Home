@tool
extends Container3D
class_name FlexContainer3D

enum Justification {
	START,
	CENTER,
	END,
	SPACE_BETWEEN,
	SPACE_AROUND,
	SPACE_EVENLY,
}

@export var justification: Justification = Justification.START:
	set(value):
		justification = value
		_update()
@export var vertical: bool = false:
	set(value):
		vertical = value
		_update()
@export var gap: float = 0.0:
	set(value):
		gap = value
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
	var width = size.y if vertical else size.x
	var child_size := Vector2(0, 0)
	var child_count = 0

	for child in get_children():
		if child is Container3D == false:
			continue

		if vertical:
			child_size.x = max(child.size.x, child_size.x)
			child_size.y += child.size.y + gap
		else:
			child_size.x += child.size.x + gap
			child_size.y = max(child.size.y, child_size.y)

		child_count += 1

	if child_count == 0:
		return

	var child_scale = Vector2(size.x, size.y) / child_size
	child_size.clamp(Vector2(0, 0), Vector2(size.x, size.y))

	child_scale = child_scale.clamp(Vector2(0.001, 0.001), Vector2(1, 1))

	var offset = 0.0

	match justification:
		Justification.START:
			offset = 0.0
		Justification.CENTER:
			offset = (width - child_size) / 2
		Justification.END:
			offset = width - child_size
		Justification.SPACE_BETWEEN:
			offset = 0.0
		Justification.SPACE_AROUND:
			offset = (width - child_size) / child_count / 2
		Justification.SPACE_EVENLY:
			offset = (width - child_size) / (child_count + 1)

	for child in get_children():
		if child is Container3D == false:
			continue

		child.scale = Vector3(child_scale.x, child_scale.y, 1)

		if vertical:
			child.position = Vector3(0, -offset, 0)
			offset += child.size.y * child_scale.y
		else:
			child.position = Vector3(offset, 0, 0)
			offset += child.size.x * child_scale.x

		match justification:
			Justification.START, Justification.CENTER, Justification.END:
				offset += gap
			Justification.SPACE_BETWEEN:
				offset += (width - child_size) / (child_count - 1)
			Justification.SPACE_AROUND:
				offset += (width - child_size) / child_count
			Justification.SPACE_EVENLY:
				offset += (width - child_size) / (child_count + 1)
			