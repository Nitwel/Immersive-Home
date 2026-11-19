extends Entity

const Entity = preload ("../entity.gd")

@onready var slider = $Slider

# Called when the node enters the scene tree for the first time.
func _ready():
	super()

	icon.value = "sliders"

	var stateInfo = await HomeApi.get_state(entity_id)
	set_state(stateInfo)

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

	slider.on_value_changed.connect(func(value):
		HomeApi.set_state(entity_id, value)
	)

func set_state(state):
	if state == null:
		return

	var attributes = state.get("attributes", {})
	if attributes == null:
		attributes = {}

	# The slider clamps its value to the current range, so the range has to be set first.
	if attributes.get("step") != null:
		slider.step = float(attributes["step"])

	if attributes.get("min") != null:
		slider.min = float(attributes["min"])

	if attributes.get("max") != null:
		slider.max = float(attributes["max"])

	if attributes.get("unit_of_measurement") != null:
		slider.label_unit = str(attributes["unit_of_measurement"])

	# "unavailable" / "unknown" keep the last known value
	var value = str(state["state"])
	if value.is_valid_float():
		slider.value = float(value)
