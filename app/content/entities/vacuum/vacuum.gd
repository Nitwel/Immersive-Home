extends Entity
## vacuum: state and battery, start/pause, stop, return to dock, locate and clean
## spot buttons, plus a fan speed dropdown. Only supported controls are shown.

const Entity = preload ("../entity.gd")
const UI = preload ("../entity_ui.gd")

const WIDTH = 0.26
## Top edge of the card; rows are stacked downwards from here.
const TOP = 0.08
const BUTTON_SIZE = 0.035
const BUTTON_GAP = 0.045

## VacuumEntityFeature flags
const FEATURE_PAUSE = 4
const FEATURE_STOP = 8
const FEATURE_RETURN_HOME = 16
const FEATURE_FAN_SPEED = 32
const FEATURE_BATTERY = 64
const FEATURE_LOCATE = 512
const FEATURE_CLEAN_SPOT = 1024
const FEATURE_START = 8192

const STATE_NAMES = {
	"cleaning": "Cleaning", "docked": "Docked", "idle": "Idle", "paused": "Paused",
	"returning": "Returning to dock", "error": "Error",
}

var panel: Panel3D
var name_label: Label3D
var state_label: Label3D
var detail_label: Label3D
var start_button: Button3D
var stop_button: Button3D
var home_button: Button3D
var locate_button: Button3D
var spot_button: Button3D
var fan_select: Select3D

var state := "unknown"
var features := 0

var _applying_state = false

func _ready():
	super()
	# The "vacuum" glyph renders with MSDF artefacts in the icon font.
	icon.value = "cleaning_services"

	panel = UI.card(self, Vector2(WIDTH, 0.15))
	UI.label(self, "cleaning_services", 22, Vector3(-WIDTH / 2 + 0.02, TOP - 0.02, 0), HORIZONTAL_ALIGNMENT_CENTER, true)
	name_label = UI.label(self, entity_id, 22, Vector3(-WIDTH / 2 + 0.034, TOP - 0.02, 0))
	state_label = UI.label(self, "", 28, Vector3(0, TOP - 0.055, 0), HORIZONTAL_ALIGNMENT_CENTER)
	detail_label = UI.label(self, "", 16, Vector3(0, TOP - 0.08, 0), HORIZONTAL_ALIGNMENT_CENTER)
	detail_label.modulate = Color(1, 1, 1, 0.7)
	start_button = UI.icon_button(self, "play_arrow", Vector3.ZERO, BUTTON_SIZE)
	stop_button = UI.icon_button(self, "stop", Vector3.ZERO, BUTTON_SIZE)
	home_button = UI.icon_button(self, "home", Vector3.ZERO, BUTTON_SIZE)
	locate_button = UI.icon_button(self, "my_location", Vector3.ZERO, BUTTON_SIZE)
	spot_button = UI.icon_button(self, "mop", Vector3.ZERO, BUTTON_SIZE)
	fan_select = UI.select(self, Vector3.ZERO, WIDTH - 0.024)
	fan_select.sort_options = false

	start_button.on_button_up.connect(_start_or_pause)
	stop_button.on_button_up.connect(func(): _send("stop"))
	home_button.on_button_up.connect(func(): _send("return_to_base"))
	locate_button.on_button_up.connect(func(): _send("locate"))
	spot_button.on_button_up.connect(func(): _send("clean_spot"))
	fan_select.on_select.connect(func(speed):
		if _applying_state or speed == null:
			return
		HomeApi.set_state(entity_id, "fan_speed", {"fan_speed": speed})
	)

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

	var speeds = attributes.get("fan_speed_list")
	if not speeds is Array:
		speeds = []
	var battery = attributes.get("battery_level")

	var fallback = FEATURE_START | FEATURE_PAUSE | FEATURE_STOP | FEATURE_RETURN_HOME \
		| (FEATURE_FAN_SPEED if not speeds.is_empty() else 0) | (FEATURE_BATTERY if battery != null else 0)
	features = UI.features_of(attributes, fallback)

	state_label.text = STATE_NAMES.get(state, state.capitalize())
	state_label.modulate = Color(1.0, 0.45, 0.3) if state == "error" else Color(1, 1, 1)

	var details = []
	if battery != null and (features & FEATURE_BATTERY) != 0:
		details.append("Battery %d %%" % int(battery))
	if attributes.get("fan_speed") != null and speeds.is_empty():
		details.append(str(attributes["fan_speed"]).capitalize())
	detail_label.text = " · ".join(details)

	var cleaning = state == "cleaning"
	var can_pause = (features & FEATURE_PAUSE) != 0
	start_button.label = "pause" if cleaning and can_pause else "play_arrow"
	_set_enabled(start_button, available and not (cleaning and not can_pause))
	_set_enabled(stop_button, available and state != "docked" and state != "idle")
	_set_enabled(home_button, available and state != "docked" and state != "returning")
	_set_enabled(locate_button, available)
	_set_enabled(spot_button, available and not cleaning)

	_applying_state = true
	var options = {}
	for speed in speeds:
		options[str(speed)] = str(speed).capitalize()
	if fan_select.options != options:
		fan_select.options = options
	fan_select.selected = UI.option_or_null(options, str(attributes.get("fan_speed")))
	_applying_state = false

	_layout((features & FEATURE_FAN_SPEED) != 0 and not speeds.is_empty())

func _layout(has_fan_speed: bool):
	var buttons = []
	for entry in [[start_button, FEATURE_START | FEATURE_PAUSE], [stop_button, FEATURE_STOP],
			[home_button, FEATURE_RETURN_HOME], [locate_button, FEATURE_LOCATE], [spot_button, FEATURE_CLEAN_SPOT]]:
		var shown = (features & entry[1]) != 0
		UI.set_shown(entry[0], shown)
		if shown:
			buttons.append(entry[0])

	var y = TOP - 0.095
	if not buttons.is_empty():
		var x = -(buttons.size() - 1) * BUTTON_GAP / 2.0
		for button in buttons:
			button.position = Vector3(x, y - 0.022, 0)
			x += BUTTON_GAP
		y -= 0.045

	UI.set_shown(fan_select, has_fan_speed)
	if has_fan_speed:
		fan_select.position = Vector3(0, y - 0.018, 0)
		y -= 0.037

	var height = TOP - y + 0.008
	UI.resize_card(self, panel, Vector2(WIDTH, height), TOP - height / 2)

func _set_enabled(button: Button3D, enabled: bool):
	button.disabled = not enabled
	UI.dim_button(button, not enabled)

func _start_or_pause():
	if state == "cleaning" and (features & FEATURE_PAUSE) != 0:
		_send("pause")
	else:
		_send("start")

func _send(action: String):
	if UI.is_unavailable(state):
		return
	HomeApi.set_state(entity_id, action)

func quick_action():
	_start_or_pause()
