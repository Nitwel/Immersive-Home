extends "../info_card.gd"
## calendar: the event running now (state "on") or the next one, with its time and
## location. Home Assistant puts that event into the attributes.

func _init():
	card_width = 0.26

func _show(_state: String, attributes: Dictionary):
	icon.value = "calendar_month"

	var message = attributes.get("message")
	if UI.is_unavailable(state):
		value_label.text = state.capitalize()
		detail_label.text = ""
		return
	if message == null or str(message) == "":
		value_label.text = ""
		detail_label.text = "No upcoming events"
		return

	value_label.text = str(message)

	var lines = ["Now · " + _time_range(attributes) if state == "on" else _time_range(attributes)]
	if attributes.get("location") != null and str(attributes["location"]) != "":
		lines.append(str(attributes["location"]))
	detail_label.text = "\n".join(lines)

## "Today 10:00–11:00", "Fri 21 Nov · All day", "Today 22:00 – Tomorrow 06:00"
func _time_range(attributes: Dictionary) -> String:
	var start = UI.parse_timestamp(attributes.get("start_time"))
	var end = UI.parse_timestamp(attributes.get("end_time"))
	if start < 0:
		return ""
	if attributes.get("all_day") == true:
		return UI.format_day(start) + " · All day"
	if end < 0:
		return "%s %s" % [UI.format_day(start), UI.format_clock(start)]
	if UI.format_day(start) == UI.format_day(end):
		return "%s %s–%s" % [UI.format_day(start), UI.format_clock(start), UI.format_clock(end)]
	return "%s %s – %s %s" % [UI.format_day(start), UI.format_clock(start), UI.format_day(end), UI.format_clock(end)]
