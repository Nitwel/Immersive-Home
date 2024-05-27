@tool
extends Container3D
class_name Select3D

const FontTools = preload ("res://lib/utils/font_tools.gd")
const SelectFont = preload ("res://assets/fonts/Raleway-Medium.ttf")
const OptionScene = preload ("./option.tscn")
const Option = preload ("./option.gd")

signal on_select(value: String)

@onready var body = $Body
@onready var panel = $Body/Panel
@onready var label = $Body/Label
@onready var icon = $Body/Icon
@onready var collision = $Body/CollisionShape3D
@onready var area_collision = $Area3D/CollisionShape3D
@onready var options_body = $Options
@onready var options_panel = $Options/Panel
@onready var options_collision = $Options/CollisionShape3D

@export var options: Dictionary = {}
@export var selected: Variant = null:
	set(value):
		if selected != value:
			on_select.emit(value)

		selected = value

		if is_node_ready() == false: return

		_update()

@export var mandatory: bool = true

@export var open: bool = false:
	set(value):
		if open == value: return

		open = value

		if is_node_ready() == false: return

		_update_options_visible()
var _options_list = []

func _ready():
	_update()
	_update_options()

func _on_focus_out(_event: EventFocus):
	open = false

func _on_press_up(event: EventPointer):
	if event.target == body:
		open = !open

	if event.target.get_parent() is Option:
		selected = event.target.get_parent().value
		open = false

func _on_touch_leave(event: EventTouch):
	if event.target == body:
		open = !open

	if event.target.get_parent() is Option:
		selected = event.target.get_parent().value
		open = false

func _update():
	if selected == null:
		label.text = "Select..."
	else:
		label.text = options[selected]

	label.position = Vector3( - size.x / 2 + 0.01, 0, 0.01)
	icon.position = Vector3(size.x / 2, 0, 0.01)

	panel.size = Vector2(size.x, size.y)
	collision.shape.size = Vector3(size.x, size.y, 0.01)
	collision.position = Vector3(0, 0, 0.005)
	area_collision.shape.size = Vector3(size.x, size.y, 0.01)
	area_collision.position = Vector3(0, 0, 0.015)

func _update_options_visible():
	options_body.visible = open
	options_collision.disabled = !open

	icon.text = "arrow_drop_up" if open else "arrow_drop_down"

	for option in _options_list:
		option.disabled = !open

func _update_options():
	for option in _options_list:
		options_body.remove_child(option)
		option.queue_free()

	_options_list.clear()

	var total_size = Vector2(0, 0)

	var display_options = options

	if mandatory == false:
		display_options[null] = "Deselect"

	var keys = display_options.keys()
	keys.sort()

	for i in range(keys.size()):
		var key = keys[i]
		var option = OptionScene.instantiate()
		option.value = key
		option.text = display_options[key]

		options_body.add_child(option)
		_options_list.append(option)

		var size = option.get_size()
		size.y += 0.01
		total_size = Vector2(max(total_size.x, size.x), total_size.y + size.y)

		option.position = Vector3(0.01, -i * size.y - 0.01, 0)

	total_size += Vector2(0.02, 0.01)
	options_panel.size = total_size
	options_panel.position = Vector3(total_size.x / 2, -total_size.y / 2, 0)
	options_body.position = Vector3( - size.x / 2, -size.y / 2, 0.02)
	options_collision.shape.size = Vector3(total_size.x, total_size.y, 0.01)
	options_collision.position = Vector3(total_size.x / 2, -total_size.y / 2, -0.005)
