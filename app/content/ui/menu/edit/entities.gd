extends Node3D

signal on_select_entity(entity_id)
signal on_back()

const EntityScene = preload ("entity.tscn")

@onready var entity_container = $FlexContainer3D
@onready var pagination = $Pagination3D
@onready var back_button = $Button

var page = R.state(0)
var page_size = 5.0
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
		for child in entity_container.get_children():
			entity_container.remove_child(child)
			child.queue_free()

		for entity in visible_entities.value:
			var entity_node=EntityScene.instantiate()
			entity_node.icon=EntityFactory.get_entity_icon(entity.split(".")[0])
			entity_node.text=entity
			entity_node.on_select.connect(func():
				on_select_entity.emit(entity)
			)
			entity_container.add_child(entity_node)

		entity_container._update()

	)
