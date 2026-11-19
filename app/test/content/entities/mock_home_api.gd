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

func get_entity_ids(domains: Array) -> Array:
	return entities.keys().filter(func(id): return domains.has(id.split(".")[0]))

## Made-up position history: every 10 minutes along a wandering route from the home
## zone to the current position (the same route every time for an entity).
func get_state_history(entity_ids: Array, start: String, _end = null) -> Dictionary:
	var from = Time.get_unix_time_from_datetime_string(start.trim_suffix("Z").trim_suffix(".000"))
	var now = Time.get_unix_time_from_system()
	var home = entities.get("zone.home", {}).get("attributes", {})
	var history = {}

	for id in entity_ids:
		var current = entities.get(id)
		if current == null:
			continue
		var attrs = current.attributes
		var entries = []
		if attrs.get("latitude") != null:
			var target = Vector2(attrs.latitude, attrs.longitude)
			var origin = Vector2(home.get("latitude", target.x), home.get("longitude", target.y))
			if origin.distance_to(target) < 0.001:
				origin = target + Vector2(0.006, -0.008) # stayed home: show a trip and back
			var rng = RandomNumberGenerator.new()
			rng.seed = hash(id)
			var steps = clampi(int((now - from) / 600.0), 2, 400)
			var wander = Vector2.ZERO
			for i in steps + 1:
				var t = float(i) / steps
				wander = wander * 0.8 + Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * 0.0008
				# Out and back when the trip ends where it started
				var along = t if origin.distance_to(target) > 0.001 else 1.0 - abs(2.0 * t - 1.0)
				var p = origin.lerp(target, along) + wander * sin(PI * t)
				var entry_attrs = attrs.duplicate()
				entry_attrs.latitude = p.x
				entry_attrs.longitude = p.y
				entries.append({"state": current.state, "attributes": entry_attrs, "time": from + t * (now - from)})
		else:
			entries.append({"state": current.state, "attributes": attrs.duplicate(), "time": now})
		history[id] = entries
	return history

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

static func _parse_duration(text) -> int:
	var parts = str(text).split(":")
	if parts.size() != 3:
		return 0
	return int(parts[0]) * 3600 + int(parts[1]) * 60 + int(parts[2])

static func _format_duration(seconds: float) -> String:
	var s = int(seconds)
	return "%d:%02d:%02d" % [floori(s / 3600.0), floori(s / 60.0) % 60, s % 60]
