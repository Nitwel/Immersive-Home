extends Node3D

signal on_select_entity(entity_id)
signal on_back()

const ButtonScene = preload ("res://content/ui/components/button/button.tscn")

@onready var grid_container = $GridContainer3D
@onready var pagination = $Pagination3D
@onready var back_button = $Button

var page = R.state(0)
var page_size = 28.0
var selected_device = R.state(null)

func _ready():
	var entities = R.computed(func(_arg):
		var devices=Store.devices.state.devices

		for device in devices:
			if device.keys()[0] == selected_device.value:
				return device.values()[0]["entities"]

		return []
	)

	var pages = R.computed(func(_arg):
		return ceil(entities.value.size() / page_size)
	)

	var visible_entities = R.computed(func(_arg):
		return entities.value.slice(page.value * page_size, page.value * page_size + page_size)
	)

	R.bind(pagination, "pages", pages)
	R.bind(pagination, "page", page, pagination.on_page_changed)

	back_button.on_button_up.connect(func():
		on_back.emit()
	)

	R.effect(func(_arg):
		for child in grid_container.get_children():
			grid_container.remove_child(child)
			child.free()

		for entity in visible_entities.value:
			var button_instance=ButtonScene.instantiate()
			button_instance.label=entity
			button_instance.on_button_down.connect(func():
				on_select_entity.emit(entity)
			)
			grid_container.add_child(button_instance)

	)
