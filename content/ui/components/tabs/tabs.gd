extends Node3D
class_name Tabs3D

signal on_select(selected: int)

var selected: Node3D
@export var initial_selected: Node3D
var proxy_group = ProxyGroup.new()

func _ready():
	if initial_selected != null:
		selected = initial_selected
		on_select.emit(selected.get_index())

	for option in get_children():
		if option is Button3D == false:
			continue

		var proxy = proxy_group.proxy(func():
			return selected == option
		, func(value: bool):
			if value == true:
				selected = option
				on_select.emit(selected.get_index())
		)

		option.external_value = proxy
