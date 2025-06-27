extends Node3D

const ButtonScene = preload ("res://content/ui/components/button/button.tscn")

@onready var devices_page = $Devices
@onready var entities_page = $Entities
@onready var spawn_sound = $SpawnSound

var selected_device = R.state(null)

func _ready():
	entities_page.selected_device = selected_device
	remove_child(entities_page)

	devices_page.on_select_device.connect(func(device):
		selected_device.value=device
		entities_page.page.value=0
	)

	entities_page.on_select_entity.connect(func(entity):
		spawn_sound.play()
		var entity_instance = App.house.create_entity(entity["id"], global_position)
		if entity_instance == null:
			EventSystem.notify("This Entity is not supported yet", EventNotify.Type.INFO)
		elif typeof(entity_instance) == TYPE_BOOL&&entity_instance == false:
			EventSystem.notify("Entity is not in Room", EventNotify.Type.INFO)
		elif entity["id"].split(".")[0] == "text": # station entity
			entity_instance.station_name = entity.name
			entity_instance.station_text_R.value = entity.name
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
