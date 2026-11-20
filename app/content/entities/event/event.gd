extends "../info_card.gd"
## event: the last event that fired (e.g. "Single press" of a remote) and how long ago.
## The state is the time of the last event.

# The "doorbell" glyph renders with MSDF artefacts in the icon font.
const ICONS = {"doorbell": "notifications","button": "touch_app", "motion": "motion_sensor_active"}

var refresh_timer := Timer.new()
var fired_at := -1

func _build():
	# Keep "5 min ago" current.
	refresh_timer.wait_time = 15.0
	refresh_timer.timeout.connect(_update_time)
	add_child(refresh_timer)
	refresh_timer.start()

func _show(_state: String, attributes: Dictionary):
	icon.value = ICONS.get(str(attributes.get("device_class", "")), "event")

	var event_type = attributes.get("event_type")
	fired_at = UI.parse_timestamp(state)
	if state == "unavailable":
		value_label.text = "Unavailable"
	elif event_type == null or fired_at < 0:
		value_label.text = "No events yet"
	else:
		value_label.text = str(event_type).capitalize()
	_update_time()

func _update_time():
	var text = UI.format_relative(fired_at) if fired_at >= 0 else ""
	if detail_label.text != text:
		detail_label.text = text
		# set_state lays out itself; only re-layout for timer ticks.
		if panel != null:
			_layout()
