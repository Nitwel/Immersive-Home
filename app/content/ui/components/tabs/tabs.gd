extends Node3D
class_name Tabs3D

signal on_select(selected: int)

var selected: Node3D:
	set(value):
		if selected == value:
			return

		if selected != null:
			selected.active = false

		selected = value
		selected.active = true
		on_select.emit(selected.get_index())
@export var initial_selected: Node3D

func _ready():
	if initial_selected != null:
		selected = initial_selected

	for option in get_children():
		if option is Button3D == false:
			continue

		option.on_button_down.connect(func():
			selected=option
		)
		
		option.toggleable = true
