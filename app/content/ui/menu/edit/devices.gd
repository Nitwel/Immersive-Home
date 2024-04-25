extends Node3D

signal on_select_device(device_id)

const ButtonScene = preload ("res://content/ui/components/button/button.tscn")

@onready var grid_container = $GridContainer3D
@onready var pagination = $Pagination3D

var page = R.state(0)
var page_size = 28.0

func _ready():

	var pages = R.computed(func(_arg):
		var devices=Store.devices.state.devices
		
		return ceil(devices.size() / page_size)
	)

	var visible_devices = R.computed(func(_arg):
		var devices=Store.devices.state.devices

		return devices.slice(page.value * page_size, page.value * page_size + page_size)
	)

	R.bind(pagination, "pages", pages)
	R.bind(pagination, "page", page, pagination.on_page_changed)

	R.effect(func(_arg):
		for child in grid_container.get_children():
			grid_container.remove_child(child)
			child.free()

		for device in visible_devices.value:
			var info=device.values()[0]

			var button_instance=ButtonScene.instantiate()
			button_instance.label=info["name"]
			button_instance.font_size=8
			button_instance.on_button_down.connect(func():
				on_select_device.emit(device.keys()[0])
			)
			grid_container.add_child(button_instance)

	)
