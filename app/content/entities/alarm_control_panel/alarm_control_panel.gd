extends Entity
## alarm_control_panel: the alarm state, a code field when the panel needs one, and
## arm buttons (home, away, night, ...) while disarmed or a disarm button while armed.

const Entity = preload ("../entity.gd")
const UI = preload ("../entity_ui.gd")

const WIDTH = 0.26
## Top edge of the card; rows are stacked downwards from here.
const TOP = 0.08
const BUTTON_SIZE = 0.04
const BUTTON_GAP = 0.05

## AlarmControlPanelEntityFeature flags
const FEATURE_ARM_HOME = 1
const FEATURE_ARM_AWAY = 2
const FEATURE_ARM_NIGHT = 4
const FEATURE_ARM_CUSTOM_BYPASS = 16
const FEATURE_ARM_VACATION = 32

## Arm actions: [action sent to HomeApi, feature flag, icon, caption]
const ARM_ACTIONS = [
	["arm_home", FEATURE_ARM_HOME, "home", "Home"],
	["arm_away", FEATURE_ARM_AWAY, "directions_walk", "Away"],
	["arm_night", FEATURE_ARM_NIGHT, "bedtime", "Night"],
	["arm_vacation", FEATURE_ARM_VACATION, "flight", "Vacation"],
	["arm_custom_bypass", FEATURE_ARM_CUSTOM_BYPASS, "tune", "Custom"],
]

## state -> [icon, label, color]
const STATES = {
	"disarmed": ["shield", "Disarmed", Color(1, 1, 1)],
	"armed_home": ["gpp_good", "Armed home", Color(0.45, 0.85, 0.5)],
	"armed_away": ["gpp_good", "Armed away", Color(0.45, 0.85, 0.5)],
	"armed_night": ["gpp_good", "Armed night", Color(0.45, 0.85, 0.5)],
	"armed_vacation": ["gpp_good", "Armed vacation", Color(0.45, 0.85, 0.5)],
	"armed_custom_bypass": ["gpp_good", "Armed custom", Color(0.45, 0.85, 0.5)],
	"arming": ["gpp_maybe", "Arming…", Color(1.0, 0.8, 0.35)],
	"disarming": ["gpp_maybe", "Disarming…", Color(1.0, 0.8, 0.35)],
	"pending": ["gpp_maybe", "Pending…", Color(1.0, 0.8, 0.35)],
	"triggered": ["notifications_active", "Triggered", Color(1.0, 0.45, 0.3)],
}

var panel: Panel3D
var header_icon: Label3D
var name_label: Label3D
var state_label: Label3D
var code_field: Input3D
## One [button, caption] per arm action, plus the disarm button last.
var arm_buttons: Array = []
var disarm_button: Button3D
var disarm_caption: Label3D

var state := "unknown"
var needs_code := false

func _ready():
	super()
	icon.value = "shield"

	panel = UI.card(self, Vector2(WIDTH, 0.15))
	header_icon = UI.label(self, "shield", 22, Vector3(-WIDTH / 2 + 0.02, TOP - 0.02, 0), HORIZONTAL_ALIGNMENT_CENTER, true)
	name_label = UI.label(self, entity_id, 22, Vector3(-WIDTH / 2 + 0.034, TOP - 0.02, 0))
	state_label = UI.label(self, "", 30, Vector3(0, TOP - 0.058, 0), HORIZONTAL_ALIGNMENT_CENTER)
	code_field = UI.input(self, Vector3.ZERO, WIDTH - 0.024)
	code_field.text = ""
	code_field.placeholder = "Code"

	for action in ARM_ACTIONS:
		var button = UI.icon_button(self, action[2], Vector3.ZERO, BUTTON_SIZE)
		var caption = UI.label(self, action[3], 12, Vector3.ZERO, HORIZONTAL_ALIGNMENT_CENTER)
		button.on_button_up.connect(func(): _send(action[0]))
		arm_buttons.append([button, caption])
	disarm_button = UI.icon_button(self, "lock_open", Vector3.ZERO, BUTTON_SIZE)
	disarm_caption = UI.label(self, "Disarm", 12, Vector3.ZERO, HORIZONTAL_ALIGNMENT_CENTER)
	disarm_button.on_button_up.connect(func(): _send("disarm"))

	set_state(await HomeApi.get_state(entity_id))

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

func set_state(state_info):
	if state_info == null:
		return

	state = str(state_info["state"])
	var attributes = UI.attributes_of(state_info)
	var available = not UI.is_unavailable(state)

	UI.fit_label(name_label, UI.entity_name(entity_id, attributes), WIDTH - 0.046)

	var look = STATES.get(state, ["shield", state.capitalize(), Color(1, 1, 1)])
	icon.value = look[0]
	header_icon.text = look[0]
	state_label.text = look[1]
	state_label.modulate = look[2]

	var features = UI.features_of(attributes, FEATURE_ARM_HOME | FEATURE_ARM_AWAY | FEATURE_ARM_NIGHT)
	var disarmed = state == "disarmed"
	var has_code = attributes.get("code_format") != null
	# Arming only asks for the code when code_arm_required is set (the default).
	needs_code = has_code and (not disarmed or attributes.get("code_arm_required", true) != false)

	var shown_buttons = []
	for i in ARM_ACTIONS.size():
		var shown = available and disarmed and (features & ARM_ACTIONS[i][1]) != 0
		UI.set_shown(arm_buttons[i][0], shown)
		arm_buttons[i][1].visible = shown
		if shown:
			shown_buttons.append(arm_buttons[i])

	var show_disarm = available and not disarmed
	UI.set_shown(disarm_button, show_disarm)
	disarm_caption.visible = show_disarm
	disarm_button.disabled = state == "disarming"
	UI.dim_button(disarm_button, disarm_button.disabled)
	if show_disarm:
		shown_buttons.append([disarm_button, disarm_caption])

	_layout(available and needs_code, shown_buttons)

func _layout(show_code: bool, buttons: Array):
	var y = TOP - 0.08

	UI.set_shown(code_field, show_code)
	if show_code:
		code_field.position = Vector3(0, y - 0.018, 0)
		y -= 0.036

	if not buttons.is_empty():
		var x = -(buttons.size() - 1) * BUTTON_GAP / 2.0
		for entry in buttons:
			entry[0].position = Vector3(x, y - 0.025, 0)
			entry[1].position = Vector3(x, y - 0.054, 0)
			x += BUTTON_GAP
		y -= 0.064

	var height = TOP - y + 0.008
	UI.resize_card(self, panel, Vector2(WIDTH, height), TOP - height / 2)

func _send(action: String):
	if UI.is_unavailable(state):
		return
	var data = {}
	if needs_code and code_field.text != "":
		data["code"] = code_field.text
	HomeApi.set_state(entity_id, action, data)
	code_field.text = ""
