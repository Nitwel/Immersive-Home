extends Node3D

signal on_select_device(device_id)

const ButtonScene = preload ("res://content/ui/components/button/button.tscn")

@onready var grid_container = $GridContainer3D
@onready var pagination = $Pagination3D
@onready var search_input: Input3D = $Input

var page = R.state(0)
var page_size = 28.0
var search = R.state("")

func _ready():
	var devices = R.computed(func(_arg):
		var devices=Store.devices.state.devices

		if search.value != "":
			return devices.filter(func(device):
				return device["name"].to_lower().find(search.value.to_lower()) != - 1||device["id"].to_lower().find(search.value.to_lower()) != - 1
			)

		return devices
	)

	var pages = R.computed(func(_arg):
		return ceil(devices.value.size() / page_size)
	)

	var visible_devices = R.computed(func(_arg):
		return devices.value.slice(page.value * page_size, page.value * page_size + page_size)
	)

	R.bind(pagination, "pages", pages)
	R.bind(pagination, "page", page, pagination.on_page_changed)
	R.bind(search_input, "text", search, search_input.on_text_changed)

	search_input.on_text_changed.connect(func(_arg):
		page.value=0
	)

	R.effect(func(_arg):
		for child in grid_container.get_children():
			grid_container.remove_child(child)
			child.free()

		for device in visible_devices.value:

			var button_instance=ButtonScene.instantiate()
			button_instance.label=device["name"]
			button_instance.font_size=8
			button_instance.on_button_up.connect(func():
				on_select_device.emit(device["id"])
			)
			grid_container.add_child(button_instance)

	)
