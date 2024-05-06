extends Node3D

signal on_select_entity(entity_id)
signal on_back()

const EntityScene = preload ("entity.tscn")

@onready var entity_container = $FlexContainer3D
@onready var pagination = $Pagination3D
@onready var back_button = $Button
@onready var search_input: Input3D = $Input

var page = R.state(0)
var page_size = 5.0
var selected_device = R.state(null)
var search = R.state("")

func _ready():
	var entities = R.computed(func(_arg):
		var devices=Store.devices.state.devices

		var entities=[]

		for device in devices:
			if device["id"] == selected_device.value:
				entities=device["entities"]
				break

		if search.value != "":
			return entities.filter(func(entity):
				return entity["name"].to_lower().find(search.value.to_lower()) != - 1||entity["id"].to_lower().find(search.value.to_lower()) != - 1
			)

		return entities
	)

	var pages = R.computed(func(_arg):
		return ceil(entities.value.size() / page_size)
	)

	var visible_entities = R.computed(func(_arg):
		return entities.value.slice(page.value * page_size, page.value * page_size + page_size)
	)

	R.bind(pagination, "pages", pages)
	R.bind(pagination, "page", page, pagination.on_page_changed)
	R.bind(search_input, "text", search, search_input.on_text_changed)

	search_input.on_text_changed.connect(func(_arg):
		page.value=0
	)

	back_button.on_button_up.connect(func():
		on_back.emit()
	)

	R.effect(func(_arg):
		for child in entity_container.get_children():
			entity_container.remove_child(child)
			child.queue_free()

		for entity in visible_entities.value:
			var entity_node=EntityScene.instantiate()
			entity_node.icon=EntityFactory.get_entity_icon(entity["id"].split(".")[0])
			entity_node.text=entity["name"]
			entity_node.on_select.connect(func():
				on_select_entity.emit(entity["id"])
			)
			entity_container.add_child(entity_node)

		entity_container._update()

	)
