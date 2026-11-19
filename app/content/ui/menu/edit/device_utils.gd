extends RefCounted
## Helpers for presenting Home Assistant devices and entities in the edit menu.

const UiFont = preload ("res://assets/fonts/ui_font_500.tres")
const IconFont = preload ("res://assets/icons/icons.tres")

## Domains in order of how well they describe a device, used to pick its icon.
const DOMAIN_PRIORITY = ["light", "climate", "media_player", "person", "device_tracker", "camera", "lock", "switch", "weather", "number", "select",
	"text", "datetime", "date", "time", "timer", "binary_sensor", "sensor", "button",
	"input_boolean", "input_number", "input_select", "input_text", "input_button", "counter", "automation", "scene", "script"]

## Domains whose state is worth showing as an on/off dot on the device.
const LIVE_DOMAINS = {"light": ["on"], "switch": ["on"], "input_boolean": ["on"], "media_player": ["on", "playing"],
	"climate": ["heat", "cool", "heat_cool", "auto", "dry", "fan_only"], "lock": ["unlocked", "open"]}

const DOMAIN_NAMES = {
	"light": "Lights",
	"switch": "Switches",
	"sensor": "Sensors",
	"binary_sensor": "Binary sensors",
	"media_player": "Media players",
	"camera": "Cameras",
	"button": "Buttons",
	"number": "Numbers",
	"timer": "Timers",
	"weather": "Weather",
	"select": "Selects",
	"climate": "Climate",
	"lock": "Locks",
	"text": "Texts",
	"date": "Dates",
	"time": "Times",
	"datetime": "Date and time",
	"input_boolean": "Toggle helpers",
	"input_number": "Number helpers",
	"input_select": "Dropdown helpers",
	"input_text": "Text helpers",
	"input_button": "Button helpers",
	"counter": "Counters",
	"automation": "Automations",
	"scene": "Scenes",
	"script": "Scripts",
	"person": "People",
	"device_tracker": "Device trackers",
}

static func domain_of(entity_id: String) -> String:
	return entity_id.split(".")[0]

## Builds the view model the edit menu works with from a device of Store.devices.
## Devices without any placeable entity return null.
static func device_view(device: Dictionary):
	var supported = []
	var unsupported = []

	for entity in device["entities"]:
		if EntityFactory.is_supported(entity["id"]):
			supported.append(entity)
		else:
			unsupported.append(entity)

	if supported.is_empty():
		return null

	var main_domain = ""
	for domain in DOMAIN_PRIORITY:
		if supported.any(func(entity): return domain_of(entity["id"]) == domain):
			main_domain = domain
			break

	var main_entity = null
	if LIVE_DOMAINS.has(main_domain):
		for entity in supported:
			if domain_of(entity["id"]) == main_domain:
				main_entity = entity["id"]
				break

	var name = device["name"]
	# Entities without a device are grouped per domain by the devices template
	if device["id"].begins_with("other.") && DOMAIN_NAMES.has(device["id"].substr(6)):
		name = DOMAIN_NAMES[device["id"].substr(6)]

	var details = []
	for key in ["manufacturer", "model"]:
		if device.get(key) != null && str(device[key]) != "" && !details.has(str(device[key])):
			details.append(str(device[key]))

	return {
		"id": device["id"],
		"name": name,
		"area": device.get("area"),
		"details": " · ".join(details),
		"icon": EntityFactory.get_entity_icon(main_domain),
		"main_entity": main_entity,
		"entities": supported + unsupported,
		"supported_count": supported.size(),
	}

## Removes a leading "Living Room " style prefix, if something is left afterwards.
static func strip_prefix(text: String, prefix) -> String:
	if prefix == null || prefix == "":
		return text

	var lower = text.to_lower()
	var lower_prefix = String(prefix).to_lower()

	if lower.begins_with(lower_prefix + " ") && text.length() > lower_prefix.length() + 1:
		var rest = text.substr(lower_prefix.length() + 1).strip_edges()
		return rest.substr(0, 1).to_upper() + rest.substr(1)

	return text

## True when every word of the query appears somewhere in the haystack.
static func matches(words: Array, haystack: String) -> bool:
	var lower = haystack.to_lower()
	for word in words:
		if lower.find(word) == -1:
			return false
	return true

static func search_words(query: String) -> Array:
	return Array(query.to_lower().split(" ", false))

## Human readable state such as "On · 80 %" or "21.4 °C".
static func format_state(entity_id: String, data) -> String:
	if data == null || typeof(data) != TYPE_DICTIONARY:
		return ""

	var state = str(data.get("state", ""))
	var attributes = data.get("attributes", {})
	if attributes == null:
		attributes = {}

	if state == "unavailable" || state == "unknown":
		return state.capitalize()

	match domain_of(entity_id):
		"light":
			if state == "on" && attributes.get("brightness") != null:
				return "On · %d %%" % roundi(float(attributes["brightness"]) / 255.0 * 100.0)
		"sensor", "number", "input_number", "counter":
			var unit = attributes.get("unit_of_measurement")
			return (state + " " + (str(unit) if unit != null else "")).strip_edges()
		"climate":
			if attributes.get("temperature") != null:
				return state.capitalize() + " · " + str(attributes["temperature"]) + " °"
		"select", "input_select", "text", "input_text", "date", "time", "datetime":
			return state
		"person", "device_tracker":
			return {"home": "Home", "not_home": "Away"}.get(state, state)
		"scene", "script", "input_button":
			return domain_of(entity_id).capitalize().replace("Input ", "")
		"media_player":
			if attributes.get("media_title") != null && (state == "playing" || state == "paused"):
				return state.capitalize() + " · " + str(attributes["media_title"])
		"weather":
			if attributes.get("temperature") != null:
				return state.capitalize() + " · " + str(attributes["temperature"]) + " °"
		"button":
			return "Button"

	return state.capitalize()

## Shortens text with an ellipsis so it fits into max_width meters at pixel_size 0.001.
static func fit_text(text: String, font_size: int, max_width: float, font: Font=UiFont) -> String:
	if text_width(text, font_size, font) <= max_width:
		return text

	var low = 0
	var high = text.length()
	while low < high:
		var mid = (low + high + 1) >> 1
		if text_width(text.substr(0, mid).strip_edges() + "…", font_size, font) <= max_width:
			low = mid
		else:
			high = mid - 1

	return text.substr(0, low).strip_edges() + "…"

static func text_width(text: String, font_size: int, font: Font=UiFont) -> float:
	return font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x * 0.001

## A Label3D styled like the rest of the menu, drawn on top of glass panels.
static func make_label(font_size: int, alpha:=1.0, alignment:=HORIZONTAL_ALIGNMENT_LEFT, icon:=false) -> Label3D:
	var label = Label3D.new()
	label.pixel_size = 0.001
	label.double_sided = false
	label.render_priority = 30
	label.outline_render_priority = 29
	label.outline_size = 0
	label.font = IconFont if icon else UiFont
	label.font_size = font_size
	label.horizontal_alignment = alignment
	label.modulate = Color(1, 1, 1, alpha)
	return label
