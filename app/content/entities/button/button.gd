extends Entity

const Entity = preload ("../entity.gd")

@onready var button = $Button

func _ready():
	super()

	icon.value = "radio_button_checked"

	var stateInfo = await HomeApi.get_state(entity_id)

	set_state(stateInfo)

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

	button.on_button_down.connect(func():
		HomeApi.set_state(entity_id, "pressed")
	)

func set_state(state):
	if state == null:
		return

	if state.attributes.has("friendly_name"):
		var name = state.attributes["friendly_name"]

		if name.begins_with("icon:"):
			name = name.substr(5)
			button.icon = true
		else:
			button.icon = false
		button.label = name

func quick_action():
	HomeApi.set_state(entity_id, "pressed")
