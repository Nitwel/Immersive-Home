extends Node3D

var entity_id = "button.plug_printer_2"
@onready var button = $Button

func _ready():
	var stateInfo = await HomeApi.get_state(entity_id)

	if stateInfo == null:
		return

	set_state(stateInfo)

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

	button.on_button_down.connect(func():
		HomeApi.set_state(entity_id, "pressed")
	)

func set_state(state):
	if state.attributes.has("friendly_name"):
		var name = state.attributes["friendly_name"]

		if name.begins_with("icon:"):
			name = name.substr(5)
			button.icon = true
		else:
			button.icon = false
		button.label = name
