extends "../info_card.gd"
## air_quality: PM2.5 (the state) as headline, other pollutants below.

## Attribute -> short name
const POLLUTANTS = [
	["air_quality_index", "AQI"], ["particulate_matter_10", "PM10"], ["particulate_matter_0_1", "PM0.1"],
	["carbon_dioxide", "CO₂"], ["carbon_monoxide", "CO"], ["nitrogen_dioxide", "NO₂"], ["nitrogen_oxide", "N₂O"],
	["nitrogen_monoxide", "NO"], ["ozone", "O₃"], ["sulphur_dioxide", "SO₂"],
]

func _show(_state: String, attributes: Dictionary):
	icon.value = "air"

	if UI.is_unavailable(state):
		value_label.text = state.capitalize()
	else:
		var unit = attributes.get("unit_of_measurement", "µg/m³")
		value_label.text = "%s %s" % [state, unit]

	var values = []
	for entry in POLLUTANTS:
		var value = attributes.get(entry[0])
		if value != null:
			values.append("%s %s" % [entry[1], _format(value)])
	var lines = ["PM2.5"] if not UI.is_unavailable(state) else []
	if not values.is_empty():
		lines.append(" · ".join(values))
	detail_label.text = "\n".join(lines)

static func _format(value) -> String:
	if value is float and not is_equal_approx(value, round(value)):
		return "%.1f" % value
	return str(int(value)) if (value is float or value is int) else str(value)
