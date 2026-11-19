extends Entity
## lock: one button that locks or unlocks, plus the current state.

const Entity = preload ("../entity.gd")
const UI = preload ("../entity_ui.gd")

const WIDTH = 0.14
const HEIGHT = 0.13

const STATES = {
	"locked": ["lock", "Locked"],
	"unlocked": ["lock_open", "Unlocked"],
	"open": ["lock_open", "Open"],
	"locking": ["lock_clock", "Locking…"],
	"unlocking": ["lock_clock", "Unlocking…"],
	"opening": ["lock_clock", "Opening…"],
	"jammed": ["warning", "Jammed"],
}

var name_label: Label3D
var state_label: Label3D
var button: Button3D
var state := "unknown"

func _ready():
	super()
	icon.value = "lock"

	UI.card(self, Vector2(WIDTH, HEIGHT))
	name_label = UI.label(self, entity_id, 20, Vector3(0, HEIGHT / 2 - 0.018, 0), HORIZONTAL_ALIGNMENT_CENTER)
	name_label.width = (WIDTH - 0.02) / name_label.pixel_size
	button = UI.icon_button(self, "lock", Vector3(0, 0.0, 0), 0.05)
	state_label = UI.label(self, "", 18, Vector3(0, -HEIGHT / 2 + 0.017, 0), HORIZONTAL_ALIGNMENT_CENTER)

	button.on_button_up.connect(_toggle)

	set_state(await HomeApi.get_state(entity_id))

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

func set_state(state_info):
	if state_info == null:
		return

	state = str(state_info["state"])
	var attributes = UI.attributes_of(state_info)

	name_label.text = UI.entity_name(entity_id, attributes)

	var look = STATES.get(state, ["question_mark", state.capitalize()])
	button.label = look[0]
	state_label.text = look[1]
	icon.value = "lock" if state == "locked" else "lock_open"

	# Pressing during a transition or while unavailable would send a conflicting command.
	var busy = state.ends_with("ing")||UI.is_unavailable(state)
	button.disabled = busy
	_set_dimmed(busy)
	state_label.modulate = Color(1.0, 0.45, 0.3) if state == "jammed" else Color(1, 1, 1, 0.8)

func _set_dimmed(dimmed: bool):
	button.get_node("Body/Label").modulate = Color(1, 1, 1, 0.4 if dimmed else 1.0)

func _toggle():
	if button.disabled:
		return
	HomeApi.set_state(entity_id, "unlock" if state == "locked" else "lock")

func quick_action():
	_toggle()
