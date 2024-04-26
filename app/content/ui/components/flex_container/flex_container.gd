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

func _update():
	var width = size.y if vertical else size.x
	var children_size := Vector2(0, 0)
	var child_count = 0

	for child in get_children():
		if child is Container3D == false:
			continue

		if vertical:
			children_size.x = max(child.size.x, children_size.x)
			children_size.y += child.size.y + gap
		else:
			children_size.x += child.size.x + gap
			children_size.y = max(child.size.y, children_size.y)

		child_count += 1

	if child_count == 0:
		return

	var children_scale = Vector2(size.x, size.y) / children_size
	children_size.clamp(Vector2(0, 0), Vector2(size.x, size.y))

	children_scale = children_scale.clamp(Vector2(0.001, 0.001), Vector2(1, 1))

	var offset = 0.0

	var children_width = children_size.y if vertical else children_size.x

	match justification:
		Justification.START:
			offset = 0.0
		Justification.CENTER:
			offset = (width - children_width) / 2.0
		Justification.END:
			offset = width - children_width
		Justification.SPACE_BETWEEN:
			offset = 0.0
		Justification.SPACE_AROUND:
			offset = (width - children_width) / child_count / 2.0
		Justification.SPACE_EVENLY:
			offset = (width - children_width) / (child_count + 1)

	for child in get_children():
		if child is Container3D == false:
			continue

		child.scale = Vector3(children_scale.x, children_scale.y, 1)

		if vertical:
			var child_width = child.size.y * children_scale.y
			
			child.position = Vector3(0, -offset - child_width / 2.0, 0)
			offset += child.size.y * children_scale.y
		else:
			var child_width = child.size.x * children_scale.x

			child.position = Vector3(offset + child_width / 2.0, 0, 0)
			offset += child.size.x * children_scale.x

		match justification:
			Justification.START, Justification.CENTER, Justification.END:
				offset += gap
			Justification.SPACE_BETWEEN:
				offset += (width - children_width) / (child_count - 1)
			Justification.SPACE_AROUND:
				offset += (width - children_width) / child_count
			Justification.SPACE_EVENLY:
				offset += (width - children_width) / (child_count + 1)
			