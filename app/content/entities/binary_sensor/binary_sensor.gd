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

	match stateInfo["state"]:
		"on":
			state.text = "check_box"
		"off":
			state.text = "check_box_outline_blank"
		"unavailable":
			state.text = "warning"
		_:
			state.text = "question_mark"

	var friendly_name = stateInfo["attributes"].get("friendly_name")
	label.text = friendly_name if friendly_name != null else entity_id

	var state_size = _get_label_size(state)
	var label_size = _get_label_size(label)

	# Labels are centered on their position, so compute the combined vertical bounds.
	var top = label.position.y + label_size.y / 2
	var bottom = state.position.y - state_size.y / 2

	collision_shape.shape.size.x = max(state_size.x, label_size.x)
	collision_shape.shape.size.y = top - bottom
	collision_shape.position.y = (top + bottom) / 2

func _get_label_size(node: Label3D) -> Vector2:
	var font_size = node.get_font().get_string_size(node.text, HORIZONTAL_ALIGNMENT_CENTER, -1, node.font_size)
	return font_size * node.pixel_size * node.scale.x