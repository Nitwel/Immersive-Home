extends Node
## In-memory stand-in for the Home Assistant adapter (lib/home_apis/hass_ws/hass.gd).
##
## Implements the same interface HomeApi forwards to, so entities can run without a
## server. set_state() simulates what the matching Home Assistant service would do and
## notifies watchers, so toggling a light in the gallery really turns it on.

# Part of the adapter interface HomeApi connects to; the mock is always connected.
@warning_ignore("unused_signal")
signal on_connect()
@warning_ignore("unused_signal")
signal on_disconnect()

var entities: Dictionary = {}
var entity_callbacks := CallbackMap.new()

## Every service call an entity made, newest last: {entity, state, attributes}.
var calls: Array = []
signal on_call(entity: String, state: Variant, attributes: Dictionary)

func _init(initial_states: Dictionary = {}):
	add_child(entity_callbacks)
	for id in initial_states:
		entities[id] = _normalize(initial_states[id])

func _normalize(state: Dictionary) -> Dictionary:
	return {"state": str(state.get("state", "unknown")), "attributes": state.get("attributes", {}).duplicate(true)}

# ---------------------------------------------------------------------------
# Adapter interface used by HomeApi
# ---------------------------------------------------------------------------

func has_connected():
	return true

func get_http_url() -> String:
	return ""

func get_devices():
	return []

func get_device(_id: String):
	return null

func get_state(entity: String):
	return entities.get(entity)

func watch_state(entity: String, callback: Callable):
	entity_callbacks.add(entity, callback)
	return func():
		entity_callbacks.remove(entity, callback)

func unwatch_owner(target: Object):
	entity_callbacks.remove_owner(target)

func set_state(entity: String, state: Variant, attributes: Dictionary = {}):
	calls.append({"entity": entity, "state": state, "attributes": attributes})
	on_call.emit(entity, state, attributes)
	print("mock_home_api: %s -> %s %s" % [entity, state, attributes])

	if not entities.has(entity):
		return null

	var current: Dictionary = entities[entity]
	var attrs: Dictionary = current.attributes

	match entity.split(".")[0]:
		"switch", "input_boolean", "automation":
			if state in ["on", "off"]:
				current.state = state
		"light":
			_simulate_light(current, state, attributes)
		"media_player":
			_simulate_media_player(current, state, attributes)
		"button", "input_button", "scene", "script":
			current.state = Time.get_datetime_string_from_system(true) + "+00:00"
		"number", "input_number", "text", "input_text", "date", "time", "datetime":
			current.state = str(state)
		"select", "input_select":
			if str(state) in attrs.get("options", []):
				current.state = str(state)
		"timer":
			_simulate_timer(current, state)
		"climate":
			_simulate_climate(current, state, attributes)
		"lock":
			_simulate_lock(entity, current, state)
		"cover":
			_simulate_cover(entity, current, state, attributes)
		"fan":
			_simulate_fan(current, state, attributes)
		"vacuum":
			_simulate_vacuum(entity, current, state, attributes)
		"alarm_control_panel":
			_simulate_alarm(entity, current, state, attributes)
		"humidifier":
			_simulate_humidifier(current, state, attributes)
		"water_heater":
			_simulate_water_heater(current, state, attributes)
		"update":
			_simulate_update(entity, current, state)
		_:
			return null

	update_entity(entity, current.state, attrs)
	return current

func has_integration():
	return false

func update_room(_room: String):
	pass

func get_voice_assistant():
	return null

## To-do items are kept in the entity's "_items" attribute.
func get_todo_items(entity_id: String):
	var state = entities.get(entity_id)
	if state == null:
		return []
	return state.attributes.get("_items", []).duplicate(true)

## Fake hourly statistics: a smooth curve around the entity's current value.
func get_history(entity_id, start, interval, _end = null):
	var state = entities.get(entity_id)
	if state == null:
		return null

	var base = float(state.state) if state.state.is_valid_float() else 20.0
	var from = Time.get_unix_time_from_datetime_string(str(start).trim_suffix(".000Z"))
	var now = Time.get_unix_time_from_system()
	var step = 3600.0 if interval == "hour" else 300.0

	var data = []
	var t = from
	while t < now:
		var mean = base + sin(t / 3600.0 / 3.0) * 2.0 + sin(t / 3600.0 / 11.0) * 1.0
		data.append({"start": t * 1000.0, "end": (t + step) * 1000.0, "mean": mean})
		t += step

	return {
		"unit": state.attributes.get("unit_of_measurement", ""),
		"has_mean": true,
		"unit_class": state.attributes.get("device_class"),
		"data": data,
	}

# ---------------------------------------------------------------------------
# Test helpers
# ---------------------------------------------------------------------------

## Replaces the state of [param entity] like a Home Assistant state_changed event would.
func update_entity(entity: String, state: Variant, attributes: Dictionary = {}, merge := true):
	if not entities.has(entity) or not merge:
		entities[entity] = {"state": str(state), "attributes": attributes.duplicate(true)}
	else:
		entities[entity].state = str(state)
		if attributes != entities[entity].attributes:
			entities[entity].attributes.merge(attributes.duplicate(true), true)
	entity_callbacks.call_key(entity, [entities[entity]])

# ---------------------------------------------------------------------------
# Service simulation
# ---------------------------------------------------------------------------

func _simulate_light(current: Dictionary, state, service_data: Dictionary):
	var attrs: Dictionary = current.attributes
	if state == "off":
		if not service_data.is_empty():
			# light.turn_off doesn't accept brightness/colour; Home Assistant rejects the call.
			push_warning("mock_home_api: light.turn_off with %s would be rejected by Home Assistant" % service_data)
			return
		current.state = "off"
		# Home Assistant reports colour attributes as null while a light is off.
		for key in ["brightness", "rgb_color", "effect"]:
			if attrs.has(key):
				attrs[key] = null
		return

	if state == "on" or service_data.has("brightness"):
		current.state = "on"
		if attrs.has("brightness") or service_data.has("brightness"):
			attrs["brightness"] = service_data.get("brightness", attrs.get("brightness") if attrs.get("brightness") != null else 255)
		if attrs.has("rgb_color"):
			attrs["rgb_color"] = service_data.get("rgb_color", attrs.get("rgb_color") if attrs.get("rgb_color") != null else [255, 220, 120])
		if service_data.has("effect"):
			attrs["effect"] = service_data["effect"]

func _simulate_media_player(current: Dictionary, state, service_data: Dictionary):
	var attrs: Dictionary = current.attributes
	match state:
		"play": current.state = "playing"
		"pause": current.state = "paused"
		"volume": attrs["volume_level"] = service_data.get("volume_level", attrs.get("volume_level", 0.5))
		"next", "previous":
			var tracks = attrs.get("_tracks", [])
			if tracks.size() > 0:
				var index = (int(attrs.get("_track", 0)) + (1 if state == "next" else -1) + tracks.size()) % tracks.size()
				attrs["_track"] = index
				attrs["media_title"] = tracks[index][0]
				attrs["media_artist"] = tracks[index][1]

func _simulate_timer(current: Dictionary, state):
	var attrs: Dictionary = current.attributes
	var duration = _parse_duration(attrs.get("duration", "00:05:00"))
	var now = Time.get_unix_time_from_system()

	match state:
		"start":
			var remaining = _parse_duration(attrs.get("remaining", attrs.get("duration", "00:05:00"))) if current.state == "paused" else duration
			attrs["finishes_at"] = Time.get_datetime_string_from_unix_time(int(now + remaining)) + "+00:00"
			current.state = "active"
		"pause":
			if current.state == "active" and attrs.get("finishes_at") != null:
				var left = max(0, Time.get_unix_time_from_datetime_string(attrs["finishes_at"]) - now)
				attrs["remaining"] = _format_duration(left)
			attrs["finishes_at"] = null
			current.state = "paused"
		"cancel":
			attrs["finishes_at"] = null
			attrs["remaining"] = attrs.get("duration")
			current.state = "idle"

func _simulate_climate(current: Dictionary, state, service_data: Dictionary):
	var attrs: Dictionary = current.attributes
	match state:
		"temperature":
			for key in ["temperature", "target_temp_low", "target_temp_high"]:
				if service_data.has(key):
					attrs[key] = service_data[key]
		"hvac_mode":
			var mode = service_data.get("hvac_mode")
			if mode in attrs.get("hvac_modes", []):
				current.state = mode
	var actions = {"off": "off", "heat": "heating", "cool": "cooling", "dry": "drying", "fan_only": "fan"}
	attrs["hvac_action"] = actions.get(current.state, "idle")

## Locks report "locking"/"unlocking" first and settle a moment later, like real ones.
func _simulate_lock(entity: String, current: Dictionary, state):
	var target = {"lock": "locked", "unlock": "unlocked", "open": "open"}.get(state)
	if target == null:
		return
	current.state = {"locked": "locking", "unlocked": "unlocking", "open": "opening"}[target]
	get_tree().create_timer(1.0).timeout.connect(func():
		update_entity(entity, target)
	)

## Increases on every cover command, so a running movement notices it was replaced.
var _cover_moves := {}

## Covers move 10 % every 0.3 s and report opening/closing meanwhile. Covers without
## current_position switch after a second.
func _simulate_cover(entity: String, current: Dictionary, state, service_data: Dictionary):
	var attrs: Dictionary = current.attributes
	var move_id = _cover_moves.get(entity, 0) + 1
	_cover_moves[entity] = move_id

	if state == "stop":
		if current.state in ["opening", "closing"]:
			current.state = "closed" if attrs.get("current_position", 1) == 0 else "open"
		return

	var target = {"open": 100, "close": 0}.get(state, service_data.get("position"))
	if target == null:
		return
	target = clampi(int(target), 0, 100)

	if attrs.get("current_position") == null:
		current.state = "opening" if target > 0 else "closing"
		get_tree().create_timer(1.0).timeout.connect(func():
			if _cover_moves[entity] == move_id:
				update_entity(entity, "open" if target > 0 else "closed")
		)
		return

	var position = int(attrs["current_position"])
	if position == target:
		return
	current.state = "opening" if target > position else "closing"
	_move_cover(entity, move_id, target)

func _move_cover(entity: String, move_id: int, target: int):
	await get_tree().create_timer(0.3).timeout
	if _cover_moves.get(entity) != move_id or not entities.has(entity):
		return
	var position = int(entities[entity].attributes["current_position"])
	position = int(move_toward(position, target, 10))
	if position == target:
		update_entity(entity, "closed" if position == 0 else "open", {"current_position": position})
	else:
		update_entity(entity, entities[entity].state, {"current_position": position})
		_move_cover(entity, move_id, target)

func _simulate_fan(current: Dictionary, state, service_data: Dictionary):
	var attrs: Dictionary = current.attributes
	match state:
		"on":
			current.state = "on"
			if attrs.has("percentage") and not attrs.get("percentage"):
				attrs["percentage"] = attrs.get("_last_percentage", 50)
		"off":
			current.state = "off"
			if attrs.get("percentage"):
				attrs["_last_percentage"] = attrs["percentage"]
				attrs["percentage"] = 0
		"percentage":
			var percentage = int(service_data.get("percentage", 0))
			attrs["percentage"] = percentage
			current.state = "on" if percentage > 0 else "off"
		"preset_mode":
			if service_data.get("preset_mode") in attrs.get("preset_modes", []):
				attrs["preset_mode"] = service_data["preset_mode"]
				current.state = "on"
		"oscillate":
			attrs["oscillating"] = service_data.get("oscillating", false)

func _simulate_vacuum(entity: String, current: Dictionary, state, service_data: Dictionary):
	var attrs: Dictionary = current.attributes
	match state:
		"start", "clean_spot": current.state = "cleaning"
		"pause": current.state = "paused"
		"stop": current.state = "idle"
		"locate": pass
		"fan_speed":
			if service_data.get("fan_speed") in attrs.get("fan_speed_list", []):
				attrs["fan_speed"] = service_data["fan_speed"]
		"return_to_base":
			current.state = "returning"
			get_tree().create_timer(2.0).timeout.connect(func():
				if entities[entity].state == "returning":
					update_entity(entity, "docked")
			)

## Arming takes a moment ("arming"), disarming is immediate. A code_format panel
## checks the code against "_code".
func _simulate_alarm(entity: String, current: Dictionary, state, service_data: Dictionary):
	var attrs: Dictionary = current.attributes
	if attrs.get("code_format") != null and (state == "disarm" or attrs.get("code_arm_required", true)):
		if str(service_data.get("code", "")) != str(attrs.get("_code", "")):
			push_warning("mock_home_api: wrong alarm code for %s" % entity)
			return
	if state == "disarm":
		current.state = "disarmed"
		return
	var target = {"arm_home": "armed_home", "arm_away": "armed_away", "arm_night": "armed_night",
		"arm_vacation": "armed_vacation", "arm_custom_bypass": "armed_custom_bypass"}.get(state)
	if target == null:
		return
	current.state = "arming"
	get_tree().create_timer(1.5).timeout.connect(func():
		if entities[entity].state == "arming":
			update_entity(entity, target)
	)

func _simulate_humidifier(current: Dictionary, state, service_data: Dictionary):
	var attrs: Dictionary = current.attributes
	match state:
		"on", "off": current.state = state
		"humidity": attrs["humidity"] = service_data.get("humidity", attrs.get("humidity"))
		"mode":
			if service_data.get("mode") in attrs.get("available_modes", []):
				attrs["mode"] = service_data["mode"]
	if attrs.has("action"):
		var wants_more = float(attrs.get("current_humidity", 0)) < float(attrs.get("humidity", 0))
		attrs["action"] = "off" if current.state == "off" else ("humidifying" if wants_more else "idle")

func _simulate_water_heater(current: Dictionary, state, service_data: Dictionary):
	var attrs: Dictionary = current.attributes
	match state:
		"temperature": attrs["temperature"] = service_data.get("temperature", attrs.get("temperature"))
		"operation_mode":
			var mode = service_data.get("operation_mode")
			if mode in attrs.get("operation_list", []):
				current.state = mode
				attrs["operation_mode"] = mode
		"on", "off":
			current.state = "eco" if state == "on" else "off"
			attrs["operation_mode"] = current.state

## Installs in 10 % steps, then reports the latest version as installed.
func _simulate_update(entity: String, current: Dictionary, state):
	var attrs: Dictionary = current.attributes
	match state:
		"skip":
			attrs["skipped_version"] = attrs.get("latest_version")
			current.state = "off"
		"install":
			attrs["in_progress"] = true
			attrs["update_percentage"] = 0
			_install_update(entity)

func _install_update(entity: String):
	await get_tree().create_timer(0.3).timeout
	if not entities.has(entity):
		return
	var attrs = entities[entity].attributes
	var progress = int(attrs.get("update_percentage", 0)) + 10
	if progress >= 100:
		update_entity(entity, "off", {"in_progress": false, "update_percentage": null,
			"installed_version": attrs.get("latest_version")})
	else:
		update_entity(entity, "on", {"update_percentage": progress})
		_install_update(entity)

static func _parse_duration(text) -> int:
	var parts = str(text).split(":")
	if parts.size() != 3:
		return 0
	return int(parts[0]) * 3600 + int(parts[1]) * 60 + int(parts[2])

static func _format_duration(seconds: float) -> String:
	var s = int(seconds)
	return "%d:%02d:%02d" % [floori(s / 3600.0), floori(s / 60.0) % 60, s % 60]
