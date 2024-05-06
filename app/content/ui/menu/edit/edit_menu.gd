extends Node3D

const ButtonScene = preload ("res://content/ui/components/button/button.tscn")

@onready var devices_page = $Devices
@onready var entities_page = $Entities

var selected_device = R.state(null)

func _ready():
	entities_page.selected_device = selected_device
	remove_child(entities_page)

	devices_page.on_select_device.connect(func(device):
		selected_device.value=device
		entities_page.page.value=0
	)

	entities_page.on_select_entity.connect(func(entity_name):
		AudioPlayer.play_effect("spawn")

		var entity=House.body.create_entity(entity_name, global_position)

		if typeof(entity) == TYPE_BOOL&&entity == false:
			EventSystem.notify("Entity is not in Room", EventNotify.Type.INFO)

		if entity == null:
			EventSystem.notify("This Entity is not supported yet", EventNotify.Type.INFO)
	)

	entities_page.on_back.connect(func():
		selected_device.value=null
	)

	R.effect(func(_arg):
		if selected_device.value == null:
			if devices_page.is_inside_tree() == false:
				add_child(devices_page)

			if entities_page.is_inside_tree():
				remove_child(entities_page)

		if selected_device.value != null:
			if entities_page.is_inside_tree() == false:
				add_child(entities_page)
			
			if devices_page.is_inside_tree():
				remove_child(devices_page)
	)
