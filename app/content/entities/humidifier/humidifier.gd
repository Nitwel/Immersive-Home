extends "../climate/climate.gd"
## humidifier: target humidity with +/- buttons, current humidity, power button and
## mode (e.g. eco, sleep). Dehumidifiers use the same widget.

const ACTIONS = {"humidifying": "Humidifying", "drying": "Drying", "idle": "Idle", "off": "Off"}

var power_button: Button3D
var is_on := false

func _build():
	icon.value = "humidity_percentage"
	header_icon.text = icon.value
	unit = "%"
	target_font_size = 48
	min_temp = 0.0
	max_temp = 100.0
	step = 1.0
	name_width = WIDTH - 0.084
	power_button = UI.icon_button(self, "power_settings_new", Vector3(WIDTH / 2 - 0.022, HEIGHT / 2 - 0.022, 0), 0.03)
	power_button.on_button_up.connect(quick_action)

func _read_limits(attributes: Dictionary):
	if attributes.get("min_humidity") != null: min_temp = float(attributes["min_humidity"])
	if attributes.get("max_humidity") != null: max_temp = float(attributes["max_humidity"])

func _read_target(attributes: Dictionary):
	target = _float_or_null(attributes.get("humidity"))

func _details(state: String, attributes: Dictionary) -> Array:
	var details = []
	if attributes.get("current_humidity") != null:
		details.append("Now %s %%" % _format(float(attributes["current_humidity"])))
	var action = attributes.get("action")
	if action != null:
		details.append(ACTIONS.get(str(action), str(action).capitalize()))
	elif state == "off":
		details.append("Off")
	return details

func _modes(attributes: Dictionary) -> Dictionary:
	return _mode_options(attributes.get("available_modes"), {})

func _current_mode(_state: String, attributes: Dictionary) -> String:
	return str(attributes.get("mode"))

func _state_changed(state: String, _attributes: Dictionary):
	is_on = state == "on"
	power_button.active = is_on
	power_button.disabled = not available
	UI.dim_button(power_button, not available)
	# The setpoint still shows while off, but faded.
	target_label.modulate = Color(1, 1, 1, 1.0 if is_on else 0.5)

func _send_target():
	if target != null:
		HomeApi.set_state(entity_id, "humidity", {"humidity": int(target)})

func _send_mode(mode: String):
	HomeApi.set_state(entity_id, "mode", {"mode": mode})

func quick_action():
	if available:
		HomeApi.set_state(entity_id, "off" if is_on else "on")
