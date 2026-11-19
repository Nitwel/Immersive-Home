extends Entity
## climate: target temperature with +/- buttons, current temperature and HVAC mode.
## Supports single setpoints ("temperature") and ranges (target_temp_low/high).

const Entity = preload ("../entity.gd")
const UI = preload ("../entity_ui.gd")

const WIDTH = 0.24
const HEIGHT = 0.17
## Wait this long after the last +/- press before sending the new setpoint.
const SEND_DELAY = 0.6

const MODE_NAMES = {
	"off": "Off", "heat": "Heat", "cool": "Cool", "heat_cool": "Heat/Cool",
	"auto": "Auto", "dry": "Dry", "fan_only": "Fan only",
}
const ACTION_NAMES = {
	"off": "Off", "heating": "Heating", "cooling": "Cooling", "drying": "Drying",
	"idle": "Idle", "fan": "Fan", "preheating": "Preheating", "defrosting": "Defrosting",
}

var name_label: Label3D
var target_label: Label3D
var current_label: Label3D
var minus_button: Button3D
var plus_button: Button3D
var mode_select: Select3D
var send_timer := Timer.new()

var available = false
var min_temp = 7.0
var max_temp = 35.0
var step = 0.5
## Shown setpoint(s); a range uses low/high, a single setpoint uses target.
var target = null
var target_low = null
var target_high = null

var _applying_state = false

func _ready():
	super()
	icon.value = "thermostat"

	UI.card(self, Vector2(WIDTH, HEIGHT))
	UI.label(self, "thermostat", 22, Vector3(-WIDTH / 2 + 0.02, HEIGHT / 2 - 0.02, 0), HORIZONTAL_ALIGNMENT_CENTER, true)
	name_label = UI.label(self, entity_id, 22, Vector3(-WIDTH / 2 + 0.034, HEIGHT / 2 - 0.02, 0))
	target_label = UI.label(self, "–", 56, Vector3(0, 0.02, 0), HORIZONTAL_ALIGNMENT_CENTER)
	current_label = UI.label(self, "", 16, Vector3(0, -0.017, 0), HORIZONTAL_ALIGNMENT_CENTER)
	current_label.modulate = Color(1, 1, 1, 0.7)
	minus_button = UI.icon_button(self, "remove", Vector3(-WIDTH / 2 + 0.03, 0.02, 0), 0.035, true)
	plus_button = UI.icon_button(self, "add", Vector3(WIDTH / 2 - 0.03, 0.02, 0), 0.035, true)
	mode_select = UI.select(self, Vector3(0, -HEIGHT / 2 + 0.025, 0), WIDTH - 0.024)
	mode_select.sort_options = false

	minus_button.on_button_down.connect(func(): _change_target(-1))
	plus_button.on_button_down.connect(func(): _change_target(1))
	mode_select.on_select.connect(_on_mode_selected)

	send_timer.one_shot = true
	send_timer.wait_time = SEND_DELAY
	send_timer.timeout.connect(_send_target)
	add_child(send_timer)

	set_state(await HomeApi.get_state(entity_id))

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

func set_state(state_info):
	if state_info == null:
		return

	var state = str(state_info["state"])
	var attributes = UI.attributes_of(state_info)
	available = not UI.is_unavailable(state)

	name_label.text = UI.entity_name(entity_id, attributes)

	if attributes.get("min_temp") != null: min_temp = float(attributes["min_temp"])
	if attributes.get("max_temp") != null: max_temp = float(attributes["max_temp"])
	if attributes.get("target_temp_step") != null: step = float(attributes["target_temp_step"])

	# Don't overwrite a setpoint the user is still adjusting.
	if send_timer.is_stopped():
		target = _float_or_null(attributes.get("temperature"))
		target_low = _float_or_null(attributes.get("target_temp_low"))
		target_high = _float_or_null(attributes.get("target_temp_high"))

	var details = []
	if attributes.get("current_temperature") != null:
		details.append("Now %s°" % _format(float(attributes["current_temperature"])))
	if attributes.get("hvac_action") != null:
		details.append(ACTION_NAMES.get(str(attributes["hvac_action"]), str(attributes["hvac_action"]).capitalize()))
	if not available:
		details = [state.capitalize()]
	current_label.text = " · ".join(details)

	_applying_state = true
	var modes = {}
	var hvac_modes = attributes.get("hvac_modes")
	if hvac_modes is Array:
		for mode in hvac_modes:
			modes[str(mode)] = MODE_NAMES.get(str(mode), str(mode).capitalize())
	if mode_select.options != modes:
		mode_select.options = modes
	mode_select.selected = state if modes.has(state) else null
	_applying_state = false

	_update_target_label()

func _update_target_label():
	var adjustable = available and (target != null or (target_low != null and target_high != null))
	minus_button.disabled = not adjustable
	plus_button.disabled = not adjustable
	minus_button.visible = adjustable
	plus_button.visible = adjustable

	# A range needs a smaller font to fit between the +/- buttons.
	target_label.font_size = 56
	if target != null:
		target_label.text = _format(target) + "°"
	elif target_low != null and target_high != null:
		target_label.text = "%s–%s°" % [_format(target_low), _format(target_high)]
		target_label.font_size = 36
	else:
		# No setpoint, e.g. while the device is off
		target_label.text = "–"

func _change_target(direction: int):
	if not available:
		return

	var delta = step * direction
	if target != null:
		target = clamp(snappedf(target + delta, step), min_temp, max_temp)
	elif target_low != null and target_high != null:
		# Move the whole range, keeping its width.
		var width = target_high - target_low
		target_low = clamp(snappedf(target_low + delta, step), min_temp, max_temp - width)
		target_high = target_low + width
	else:
		return

	_update_target_label()
	send_timer.start()

func _send_target():
	if target != null:
		HomeApi.set_state(entity_id, "temperature", {"temperature": target})
	elif target_low != null and target_high != null:
		HomeApi.set_state(entity_id, "temperature", {"target_temp_low": target_low, "target_temp_high": target_high})

func _on_mode_selected(mode):
	if _applying_state||mode == null:
		return
	HomeApi.set_state(entity_id, "hvac_mode", {"hvac_mode": mode})

func quick_action():
	if mode_select.options.size() < 2:
		return
	# Toggle between off and the first other mode
	var current = mode_select.selected
	var other = mode_select.options.keys().filter(func(mode): return mode != "off")
	HomeApi.set_state(entity_id, "hvac_mode", {"hvac_mode": other[0] if current == "off" else "off"})

static func _float_or_null(value):
	return float(value) if value != null else null

## 21.0 -> "21", 21.5 -> "21.5"
static func _format(value: float) -> String:
	return str(int(value)) if is_equal_approx(value, round(value)) else "%.1f" % value
