@tool
extends FlexContainer3D
class_name Tabs3D

signal on_select(selected: int)

var selected = R.state(0)

@export var initial_selected: Node3D

func _ready():
	_update()

	if Engine.is_editor_hint():
		return

	if initial_selected:
		selected.value = initial_selected.get_index()

	for option in get_children():
		if option is Button3D == false:
			continue

		option.on_button_down.connect(func():
			selected.value=option.get_index()
			on_select.emit(option.get_index())
		)

		R.effect(func(_arg):
			option.active=option.get_index() == selected.value
			option.disabled=option.get_index() == selected.value
		)
		
		option.toggleable = true