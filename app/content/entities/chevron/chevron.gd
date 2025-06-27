extends Entity

const Entity = preload ("../entity.gd")

@onready var chevron = $Chevron

func _ready():
	super()

	icon.value = "radio_button_checked" # Need to change this to a custom icon

	var stateInfo = await HomeApi.get_state(entity_id)

	if stateInfo == null:
		return

	set_state(stateInfo)

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

	chevron.on_button_down.connect(func():
		HomeApi.set_state(entity_id, "pressed")
	)

func set_state(state):
	if state.attributes.has("friendly_name"):
		var name = state.attributes["friendly_name"]

		if name.begins_with("icon:"):
			name = name.substr(5)
			chevron.icon = true
		else:
			chevron.icon = false
		chevron.label = name

func quick_action():
	HomeApi.set_state(entity_id, "pressed")
