extends Entity
## text / input_text: an input field. The value is sent when the user presses
## Enter or leaves the field, not on every keystroke.

const Entity = preload ("../entity.gd")
const UI = preload ("../entity_ui.gd")

const WIDTH = 0.26
const HEIGHT = 0.08

var name_label: Label3D
var field: Input3D

## Last value Home Assistant reported; only changed text is sent.
var value := ""
var max_length := 255
var min_length := 0

func _ready():
	super()
	icon.value = "text_fields"

	UI.card(self, Vector2(WIDTH, HEIGHT))
	name_label = UI.label(self, entity_id, 22, Vector3(-WIDTH / 2 + 0.012, HEIGHT / 2 - 0.018, 0))
	field = UI.input(self, Vector3(0, -0.012, 0), WIDTH - 0.024)

	EventSystem.on_focus_out.connect(func(event: EventFocus):
		if event.previous_target == field:
			_commit()
	)
	field.on_submit.connect(func(_text): _commit())

	set_state(await HomeApi.get_state(entity_id))

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

func set_state(state_info):
	if state_info == null:
		return

	var state = str(state_info["state"])
	var attributes = UI.attributes_of(state_info)

	name_label.text = UI.entity_name(entity_id, attributes)
	if attributes.get("max") != null: max_length = int(attributes["max"])
	if attributes.get("min") != null: min_length = int(attributes["min"])

	# "unknown" means no value yet, which the user can still set.
	field.disabled = state == "unavailable"
	value = "" if UI.is_unavailable(state) else state

	# Don't replace what the user is typing.
	if not EventSystem.is_focused(field):
		field.text = value
		field.placeholder = state.capitalize() if UI.is_unavailable(state) else ""

func _commit():
	var text = field.text.substr(0, max_length)
	if text == value or text.length() < min_length:
		# Too short for Home Assistant (it would reject it): show the stored value again.
		field.text = value
		return

	value = text
	HomeApi.set_state(entity_id, text)
