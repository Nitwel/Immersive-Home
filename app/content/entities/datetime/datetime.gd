extends Entity
## date / time / datetime: the value split into fields (day, month, year, hour,
## minute), each with up/down buttons. Changes are sent once the user stops pressing.
##
## Internally the value is kept as "wall clock" seconds: local time expressed as if
## it were UTC, so Time's dict helpers can be used without time zone math. For the
## time domain it is the seconds since midnight. datetime states are UTC in Home
## Assistant and get converted to local time for display.

const Entity = preload ("../entity.gd")
const UI = preload ("../entity_ui.gd")

const SEND_DELAY = 0.8
const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
const DAY = 86400

## [field, column width, separator drawn after it]
const LAYOUTS = {
	"date": [["day", 0.04, ""], ["month", 0.055, ""], ["year", 0.07, ""]],
	"time": [["hour", 0.04, ":"], ["minute", 0.04, ""]],
	"datetime": [["day", 0.04, ""], ["month", 0.055, ""], ["year", 0.07, ""], ["hour", 0.04, ":"], ["minute", 0.04, ""]],
}

var mode := "date"
var name_label: Label3D
var field_labels := {}
var buttons: Array[Button3D] = []
var send_timer := Timer.new()

## Wall clock seconds, or null when the state is unknown/unavailable.
var value = null
var available = false

func _ready():
	super()
	mode = entity_id.split(".")[0]
	if not LAYOUTS.has(mode):
		mode = "datetime"
	icon.value = {"date": "calendar_today", "time": "schedule", "datetime": "event"}[mode]

	_build()

	send_timer.one_shot = true
	send_timer.wait_time = SEND_DELAY
	send_timer.timeout.connect(_send)
	add_child(send_timer)

	set_state(await HomeApi.get_state(entity_id))

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

func _build():
	var layout = LAYOUTS[mode]
	var gap = 0.01
	var date_time_gap = 0.025 # between the year and the hour in datetime mode
	var content_width = 0.0
	for i in layout.size():
		content_width += layout[i][1] + (gap if i < layout.size() - 1 else 0.0)
	if mode == "datetime":
		content_width += date_time_gap
	var width = max(content_width + 0.03, 0.16)
	var height = 0.15

	UI.card(self, Vector2(width, height))
	name_label = UI.label(self, entity_id, 20, Vector3(-width / 2 + 0.012, height / 2 - 0.016, 0))

	var x = -content_width / 2
	for i in layout.size():
		var field = layout[i][0]
		var column = layout[i][1]
		var center = x + column / 2
		var up = UI.icon_button(self, "keyboard_arrow_up", Vector3(center, 0.032, 0), 0.03, true)
		var down = UI.icon_button(self, "keyboard_arrow_down", Vector3(center, -0.052, 0), 0.03, true)
		up.on_button_down.connect(func(): _step(field, 1))
		down.on_button_down.connect(func(): _step(field, -1))
		buttons.append_array([up, down])
		field_labels[field] = UI.label(self, "–", 30, Vector3(center, -0.01, 0), HORIZONTAL_ALIGNMENT_CENTER)

		x += column
		if layout[i][2] != "":
			UI.label(self, layout[i][2], 30, Vector3(x + gap / 2, -0.01, 0), HORIZONTAL_ALIGNMENT_CENTER)
		if i < layout.size() - 1:
			x += gap
		if field == "year" and mode == "datetime":
			x += date_time_gap

func set_state(state_info):
	if state_info == null:
		return

	var state = str(state_info["state"])
	var attributes = UI.attributes_of(state_info)

	name_label.text = UI.entity_name(entity_id, attributes)
	# "unknown" means never set: still editable (the first press starts from now).
	available = state != "unavailable"
	for button in buttons:
		button.disabled = not available

	# Keep the value the user is still adjusting.
	if send_timer.is_stopped():
		value = _parse(state) if not UI.is_unavailable(state) else null
	_update_labels()

func _update_labels():
	if value == null:
		for field in field_labels:
			field_labels[field].text = "–"
		return

	var d = Time.get_datetime_dict_from_unix_time(value)
	var texts = {
		"day": "%02d" % d.day, "month": MONTHS[d.month - 1], "year": str(d.year),
		"hour": "%02d" % d.hour, "minute": "%02d" % d.minute,
	}
	for field in field_labels:
		field_labels[field].text = texts[field]

func _step(field: String, direction: int):
	if not available:
		return
	if value == null:
		value = _now_wall_clock()
		if mode == "time":
			value = posmod(value, DAY)
		elif mode == "date":
			value -= posmod(value, DAY)

	match field:
		"minute": value += 60 * direction
		"hour": value += 3600 * direction
		"day": value += DAY * direction
		"month", "year":
			var d = Time.get_datetime_dict_from_unix_time(value)
			if field == "month":
				var month = d.month - 1 + direction
				d.year += floori(month / 12.0)
				d.month = posmod(month, 12) + 1
			else:
				d.year += direction
			d.day = min(d.day, _days_in_month(d.year, d.month))
			value = Time.get_unix_time_from_datetime_dict(d)

	if mode == "time":
		value = posmod(value, DAY) # 23:59 + 1 minute wraps to 00:00 instead of changing the day

	_update_labels()
	send_timer.start()

func _send():
	if value == null:
		return

	match mode:
		"date":
			HomeApi.set_state(entity_id, Time.get_date_string_from_unix_time(value))
		"time":
			HomeApi.set_state(entity_id, Time.get_time_string_from_unix_time(value))
		"datetime":
			var utc = value - _utc_offset()
			HomeApi.set_state(entity_id, Time.get_datetime_string_from_unix_time(utc) + "+00:00")

## Parses a date ("2024-01-31"), time ("14:30:00") or datetime
## ("2024-01-31T13:30:00+00:00") state into wall clock seconds, or null.
func _parse(state: String):
	match mode:
		"date":
			return _parse_date(state)
		"time":
			return _parse_time(state)
		_:
			var parts = state.replace(" ", "T").split("T")
			if parts.size() != 2:
				return null
			var date = _parse_date(parts[0])
			var time_text = parts[1]
			var offset = 0
			# Split off "+01:00", "-05:00" or "Z"
			if time_text.ends_with("Z"):
				time_text = time_text.trim_suffix("Z")
			else:
				for tz_sign in ["+", "-"]:
					var at = time_text.rfind(tz_sign)
					if at > 0:
						var tz = _parse_time(time_text.substr(at + 1))
						if tz != null:
							offset = tz * (1 if tz_sign == "+" else -1)
						time_text = time_text.substr(0, at)
						break
			var time = _parse_time(time_text)
			if date == null or time == null:
				return null
			return date + time - offset + _utc_offset()

static func _parse_date(text: String):
	var parts = text.split("-")
	if parts.size() != 3 or not (parts[0].is_valid_int() and parts[1].is_valid_int() and parts[2].is_valid_int()):
		return null
	return Time.get_unix_time_from_datetime_dict({"year": int(parts[0]), "month": int(parts[1]), "day": int(parts[2]), "hour": 0, "minute": 0, "second": 0})

static func _parse_time(text: String):
	var parts = text.split(":")
	if parts.size() < 2:
		return null
	var seconds = 0
	for i in range(min(parts.size(), 3)):
		var part = parts[i].split(".")[0] # drop fractional seconds
		if not part.is_valid_int():
			return null
		seconds += int(part) * [3600, 60, 1][i]
	return seconds

static func _days_in_month(year: int, month: int) -> int:
	if month == 2:
		return 29 if (year % 4 == 0 and year % 100 != 0) or year % 400 == 0 else 28
	return 30 if month in [4, 6, 9, 11] else 31

## Seconds to add to UTC to get local time (the system's current offset).
static func _utc_offset() -> int:
	return int(Time.get_time_zone_from_system().bias) * 60

static func _now_wall_clock() -> int:
	return int(Time.get_unix_time_from_system()) + _utc_offset()
