extends Entity

const Entity = preload ("../entity.gd")

@onready var label: Label3D = $Label
@onready var state: Label3D = $State
@onready var collision_shape = $CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready():
	super()

	icon.value = "sensors"

	var stateInfo = await HomeApi.get_state(entity_id)
	set_text(stateInfo)

	await HomeApi.watch_state(entity_id, func(new_state):
		set_text(new_state)
	)

func set_text(stateInfo):
	if stateInfo == null:
		return

	state.text = "check_box" if stateInfo["state"] == "True" else "check_box_outline_blank"

	if stateInfo["attributes"]["friendly_name"] != null:
		label.text = stateInfo["attributes"]["friendly_name"]

	var state_font = state.get_font()
	var state_size = state_font.get_string_size(state.text, HORIZONTAL_ALIGNMENT_LEFT, -1, state.font_size) * state.pixel_size
	var label_font = label.get_font()
	var label_size = label_font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_RIGHT, -1, label.font_size) * label.pixel_size

	var size = Vector2(max(state_size.x, label_size.x) * 0.5, (state_size.y + label_size.y) * 0.25)

	collision_shape.shape.size.x = size.x
	collision_shape.shape.size.y = size.y