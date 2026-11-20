extends "../info_card.gd"
## sun: above/below the horizon, next sunrise and sunset, elevation.

func _init():
	card_width = 0.26

func _show(_state: String, attributes: Dictionary):
	var up = state == "above_horizon"
	icon.value = "wb_sunny" if up else "bedtime"
	value_label.text = {"above_horizon": "Above horizon", "below_horizon": "Below horizon"}.get(state, state.capitalize())

	var lines = []
	var times = []
	for entry in [["next_rising", "Sunrise"], ["next_setting", "Sunset"]]:
		var unix = UI.parse_timestamp(attributes.get(entry[0]))
		if unix >= 0:
			times.append([unix, "%s %s" % [entry[1], UI.format_clock(unix)]])
	# Next event first
	times.sort_custom(func(a, b): return a[0] < b[0])
	if not times.is_empty():
		lines.append(" · ".join(times.map(func(t): return t[1])))
	if attributes.get("elevation") != null:
		lines.append("Elevation %.1f°" % float(attributes["elevation"]))
	detail_label.text = "\n".join(lines)
