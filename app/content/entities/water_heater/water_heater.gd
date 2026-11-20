extends "../climate/climate.gd"
## water_heater: target temperature with +/- buttons, current temperature and the
## operation mode (eco, electric, heat pump, ...). Its state is the operation mode.

const OPERATION_NAMES = {
	"off": "Off", "eco": "Eco", "electric": "Electric", "gas": "Gas", "heat_pump": "Heat pump",
	"high_demand": "High demand", "performance": "Performance",
}

func _build():
	icon.value = "water_heater"
	header_icon.text = icon.value
	step = 1.0
	min_temp = 30.0
	max_temp = 70.0

func _read_target(attributes: Dictionary):
	super(attributes)
	# Only show a range when the heater has no single setpoint.
	if target != null:
		target_low = null
		target_high = null

func _details(state: String, attributes: Dictionary) -> Array:
	var details = []
	if attributes.get("current_temperature") != null:
		details.append("Now %s°" % _format(float(attributes["current_temperature"])))
	if attributes.get("away_mode") == "on":
		details.append("Away")
	elif attributes.get("operation_list") == null and state != "":
		# Without a dropdown, the mode goes here.
		details.append(OPERATION_NAMES.get(state, state.capitalize()))
	return details

func _modes(attributes: Dictionary) -> Dictionary:
	return _mode_options(attributes.get("operation_list"), OPERATION_NAMES)

func _current_mode(state: String, attributes: Dictionary) -> String:
	return str(attributes.get("operation_mode", state))

func _send_mode(mode: String):
	HomeApi.set_state(entity_id, "operation_mode", {"operation_mode": mode})
