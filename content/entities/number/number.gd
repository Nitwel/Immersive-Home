extends Entity

const Entity = preload ("../entity.gd")

@onready var slider = $Slider

# Called when the node enters the scene tree for the first time.
func _ready():
	super()

	var stateInfo = await HomeApi.get_state(entity_id)
	if stateInfo == null:
		return

	set_state(stateInfo)

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

	slider.on_value_changed.connect(func(value):
		HomeApi.set_state(entity_id, value)
	)

func set_state(state):
	slider.value = float(state["state"])
	
	var attributes = state["attributes"]

	if attributes.has("min"):
		slider.min = float(attributes["min"])
	
	if attributes.has("max"):
		slider.max = float(attributes["max"])

	if attributes.has("step"):
		slider.step = float(attributes["step"])
