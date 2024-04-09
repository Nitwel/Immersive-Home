extends Node3D
class_name Tabs3D

signal on_select(selected: int)

var selected = R.state(null)

@export var initial_selected: Node3D

func _ready():
	if initial_selected:
		selected.value = initial_selected

	R.effect(func(_arg):
		on_select.emit(selected.value)
	)

	for option in get_children():
		if option is Button3D == false:
			continue

		option.on_button_down.connect(func():
			selected.value=option
		)

		R.effect(func(_arg):
			option.active=option == selected.value
			option.disabled=option == selected.value
		)
		
		option.toggleable = true
