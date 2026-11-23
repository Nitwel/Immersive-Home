extends "res://lib/home_apis/demo/simulated_api.gd"
## Adapter for the demo mode: a made-up home with fake devices, so the app can be
## shown without a Home Assistant server.
##
## Services are simulated by the base class (toggling a light turns it on). On top of
## that, sensors drift a little, the bathroom gets steamy now and then, and two people
## travel around the city on fixed routes, so their position history and live
## position always match. The rooms the devices are placed in come from
## demo_house.gd. Everything here is made up: names, places and devices.

## Seconds between two simulated updates.
const TICK = 5.0

## Made-up home location near a public landmark (Brandenburg Gate, Berlin), the same
## one the entity gallery uses. Vector2(latitude, longitude).
const HOME = Vector2(52.5163, 13.3777)
const HOME_RADIUS = 100.0

## Zones besides home: entity id -> [name, position, radius in meters].
const ZONES = {
	"zone.work": ["Work", Vector2(52.5251, 13.3694), 150.0],
	"zone.gym": ["Gym", Vector2(52.5079, 13.3933), 80.0],
}

## Where the demo people go. Every [code]period[/code] seconds a person spends
## [code]home_share[/code] of the time at home, then visits the stops and comes back.
## [code]offset[/code] shifts the schedule, so the two aren't in sync.
const ROUTES = {
	"person.alex": {"tracker": "device_tracker.alex_phone", "period": 3 * 3600.0, "offset": 0.0, "home_share": 0.55,
		"stops": [Vector2(52.5251, 13.3694), Vector2(52.5208, 13.4095)]},
	"person.sam": {"tracker": "device_tracker.sam_phone", "period": 5400.0, "offset": 1800.0, "home_share": 0.3,
		"stops": [Vector2(52.5079, 13.3933), Vector2(52.5145, 13.3501)]},
}

## Seconds between two recorded positions in the position history.
const HISTORY_STEP = 120.0

## Temperature/humidity sensor id -> the value it drifts around.
var _baselines := {}

func _init(_url: String="", _token: String=""):
	super(_states())
	devices = _devices()

	for id in entities:
		if id.begins_with("sensor.") and entities[id].state.is_valid_float():
			_baselines[id] = float(entities[id].state)

func _ready():
	_update_people()

	var timer = Timer.new()
	timer.wait_time = TICK
	timer.autostart = true
	timer.timeout.connect(_tick)
	add_child(timer)

	# HomeApi connects to on_connect right after adding the adapter.
	on_connect.emit.call_deferred()

func _tick():
	_drift_sensors()
	_update_people()

# ---------------------------------------------------------------------------
# Live simulation
# ---------------------------------------------------------------------------

## Sensors wander around their baseline. Now and then someone showers, which
## sends the bathroom humidity up; it slowly settles afterwards.
func _drift_sensors():
	if randf() < TICK / 900.0:
		_baselines["sensor.bathroom_humidity"] = 88.0
	else:
		_baselines["sensor.bathroom_humidity"] = move_toward(_baselines["sensor.bathroom_humidity"], 62.0, 0.4)

	for id in _baselines:
		var is_humidity = entities[id].attributes.get("device_class") == "humidity"
		var value = float(entities[id].state)
		var target = _baselines[id]
		value += (target - value) * 0.08 + randf_range(-0.05, 0.05) * (4.0 if is_humidity else 1.0)
		update_entity(id, ("%.0f" if is_humidity else "%.1f") % value)

	# The thermostat's own reading follows the living room sensor.
	var climate = entities["climate.living_room_thermostat"].attributes
	climate.current_temperature = snappedf(float(entities["sensor.living_room_temperature"].state), 0.1)
	_baselines["sensor.living_room_temperature"] = float(climate.temperature) - 0.3 if entities["climate.living_room_thermostat"].state == "heat" else 19.5
	update_entity("climate.living_room_thermostat", entities["climate.living_room_thermostat"].state)

func _update_people():
	var now = Time.get_unix_time_from_system()

	for person in ROUTES:
		var route = ROUTES[person]
		var position = route_position(route, now)
		var location = {"latitude": position.x, "longitude": position.y}
		var state = _zone_state(position)
		update_entity(route.tracker, state, location)
		update_entity(person, state, location)

## Where someone on [param route] is at [param unix] time.
static func route_position(route: Dictionary, unix: float) -> Vector2:
	var phase = fposmod(unix + route.offset, route.period) / route.period
	if phase < route.home_share:
		return HOME

	var points = _street_path([HOME] + route.stops + [HOME])
	var lengths = []
	var total = 0.0
	for i in points.size() - 1:
		var length = points[i].distance_to(points[i + 1])
		lengths.append(length)
		total += length

	var distance = (phase - route.home_share) / (1.0 - route.home_share) * total
	for i in lengths.size():
		if distance <= lengths[i]:
			return points[i].lerp(points[i + 1], distance / lengths[i] if lengths[i] > 0.0 else 0.0)
		distance -= lengths[i]
	return HOME

## Goes north/south first and then east/west between stops, so paths look like they
## follow streets instead of cutting straight through blocks.
static func _street_path(stops: Array) -> Array:
	var points = [stops[0]]
	for i in range(1, stops.size()):
		var from: Vector2 = stops[i - 1]
		var to: Vector2 = stops[i]
		points.append(Vector2(to.x, from.y))
		points.append(to)
	return points

## Home Assistant's state for a tracker at [param position]: home, a zone name or not_home.
static func _zone_state(position: Vector2) -> String:
	if _meters(position, HOME) <= HOME_RADIUS:
		return "home"
	for id in ZONES:
		if _meters(position, ZONES[id][1]) <= ZONES[id][2]:
			return ZONES[id][0]
	return "not_home"

static func _meters(a: Vector2, b: Vector2) -> float:
	var lat = deg_to_rad((a.x + b.x) / 2.0)
	return Vector2((a.x - b.x) * 111320.0, (a.y - b.y) * 111320.0 * cos(lat)).length()

# ---------------------------------------------------------------------------
# Adapter interface
# ---------------------------------------------------------------------------

## The people's recorded positions come from their routes, so the path on the map
## ends exactly where they are now.
func get_state_history(entity_ids: Array, start: String, end=null) -> Dictionary:
	var from = Time.get_unix_time_from_datetime_string(start.trim_suffix("Z").trim_suffix(".000"))
	var now = Time.get_unix_time_from_system()
	var history = super(entity_ids.filter(func(id): return _route_of(id) == null), start, end)

	for id in entity_ids:
		var route = _route_of(id)
		if route == null or not entities.has(id):
			continue

		var entries = []
		var t = from
		while t <= now:
			var position = route_position(route, t)
			var attributes = entities[id].attributes.duplicate()
			attributes.latitude = position.x
			attributes.longitude = position.y
			entries.append({"state": _zone_state(position), "attributes": attributes, "time": t})
			t += HISTORY_STEP
		history[id] = entries

	return history

func _route_of(entity_id: String):
	for person in ROUTES:
		if person == entity_id or ROUTES[person].tracker == entity_id:
			return ROUTES[person]
	return null

# ---------------------------------------------------------------------------
# The demo home
# ---------------------------------------------------------------------------

func _states() -> Dictionary:
	var now = Time.get_unix_time_from_system()
	var states = {
		# Living Room
		"light.living_room_ceiling": {"state": "on", "attributes": {
			"friendly_name": "Living Room Ceiling", "brightness": 180, "rgb_color": [255, 190, 120],
			"supported_color_modes": ["rgb"], "color_mode": "rgb",
			"effect_list": ["None", "Candle", "Rainbow"], "effect": "None"}},
		"light.living_room_floor_lamp": {"state": "on", "attributes": {
			"friendly_name": "Living Room Floor Lamp", "brightness": 110, "supported_color_modes": ["brightness"]}},
		"media_player.living_room_speaker": {"state": "playing", "attributes": {
			"friendly_name": "Living Room Speaker", "media_title": "Morning Light", "media_artist": "The Demo Band",
			"volume_level": 0.3, "_tracks": [["Morning Light", "The Demo Band"], ["Paper Planes", "Sample Collective"], ["Quiet Hours", "Placeholder Trio"]]}},
		"climate.living_room_thermostat": {"state": "heat", "attributes": {
			"friendly_name": "Living Room Thermostat", "hvac_modes": ["off", "heat", "auto"], "hvac_action": "heating",
			"current_temperature": 21.1, "temperature": 21.5, "min_temp": 7, "max_temp": 30, "target_temp_step": 0.5}},
		"sensor.living_room_temperature": _sensor("Living Room Temperature", "21.2", "°C", "temperature"),
		"sensor.living_room_humidity": _sensor("Living Room Humidity", "46", "%", "humidity"),
		"cover.living_room_blinds": {"state": "open", "attributes": {
			"friendly_name": "Living Room Blinds", "device_class": "blind", "current_position": 70, "supported_features": 15}},
		"binary_sensor.balcony_door": {"state": "off", "attributes": {"friendly_name": "Balcony Door", "device_class": "door"}},
		"lock.front_door": {"state": "locked", "attributes": {"friendly_name": "Front Door"}},
		"vacuum.robot_vacuum": {"state": "docked", "attributes": {
			"friendly_name": "Robot Vacuum", "battery_level": 86, "fan_speed": "balanced",
			"fan_speed_list": ["quiet", "balanced", "turbo"], "supported_features": 13948}},
		"weather.home": {"state": "partlycloudy", "attributes": {
			"friendly_name": "Home", "temperature": 14.5, "temperature_unit": "°C",
			"humidity": 62, "pressure": 1016, "wind_speed": 9.0}},

		# Kitchen
		"light.kitchen_spots": {"state": "off", "attributes": {
			"friendly_name": "Kitchen Spots", "supported_color_modes": ["brightness"]}},
		"switch.coffee_machine": {"state": "off", "attributes": {"friendly_name": "Coffee Machine"}},
		"timer.oven": {"state": "idle", "attributes": {"friendly_name": "Oven", "duration": "0:20:00", "remaining": "0:20:00"}},
		"sensor.kitchen_temperature": _sensor("Kitchen Temperature", "22.6", "°C", "temperature"),
		"sensor.kitchen_humidity": _sensor("Kitchen Humidity", "53", "%", "humidity"),
		"sensor.dishwasher_status": {"state": "Running", "attributes": {"friendly_name": "Dishwasher"}},
		"binary_sensor.kitchen_window": {"state": "on", "attributes": {"friendly_name": "Kitchen Window", "device_class": "window"}},
		"todo.shopping_list": {"state": "3", "attributes": {"friendly_name": "Shopping List", "_items": [
			{"uid": "1", "summary": "Oat milk", "status": "needs_action"},
			{"uid": "2", "summary": "Tomatoes", "status": "needs_action"},
			{"uid": "3", "summary": "Coffee beans", "status": "needs_action"},
			{"uid": "4", "summary": "Bread", "status": "completed"}]}},

		# Bedroom
		"light.bedside_lamp": {"state": "on", "attributes": {
			"friendly_name": "Bedside Lamp", "brightness": 70, "rgb_color": [255, 140, 70],
			"supported_color_modes": ["rgb"], "color_mode": "rgb"}},
		"cover.bedroom_curtains": {"state": "closed", "attributes": {
			"friendly_name": "Bedroom Curtains", "device_class": "curtain", "current_position": 0, "supported_features": 15}},
		"sensor.bedroom_temperature": _sensor("Bedroom Temperature", "19.4", "°C", "temperature"),
		"sensor.bedroom_humidity": _sensor("Bedroom Humidity", "49", "%", "humidity"),
		"humidifier.bedroom_humidifier": {"state": "off", "attributes": {
			"friendly_name": "Bedroom Humidifier", "humidity": 50, "current_humidity": 49, "min_humidity": 30,
			"max_humidity": 80, "mode": "normal", "available_modes": ["normal", "eco", "sleep"],
			"action": "off", "device_class": "humidifier", "supported_features": 1}},
		"time.wake_up_alarm": {"state": "06:45:00", "attributes": {"friendly_name": "Wake-up Alarm"}},
		"calendar.family": {"state": "off", "attributes": {
			"friendly_name": "Family", "message": "Dinner with friends", "all_day": false,
			"start_time": _local(now + 4 * 3600), "end_time": _local(now + 6 * 3600), "location": "Riverside Bistro"}},

		# Bathroom
		"light.bathroom_mirror": {"state": "off", "attributes": {
			"friendly_name": "Bathroom Mirror", "supported_color_modes": ["brightness"]}},
		"fan.bathroom_fan": {"state": "off", "attributes": {
			"friendly_name": "Bathroom Fan", "percentage": 0, "percentage_step": 33.333333, "supported_features": 49}},
		"sensor.bathroom_temperature": _sensor("Bathroom Temperature", "23.4", "°C", "temperature"),
		"sensor.bathroom_humidity": _sensor("Bathroom Humidity", "64", "%", "humidity"),
		"water_heater.boiler": {"state": "eco", "attributes": {
			"friendly_name": "Boiler", "temperature": 55, "current_temperature": 51, "min_temp": 40, "max_temp": 65,
			"operation_list": ["off", "eco", "electric", "performance"], "operation_mode": "eco", "supported_features": 15}},

		# Whole home
		"alarm_control_panel.home_alarm": {"state": "disarmed", "attributes": {
			"friendly_name": "Home Alarm", "code_format": null, "supported_features": 3}},
		"update.home_assistant_core": {"state": "on", "attributes": {
			"friendly_name": "Home Assistant Core Update", "title": "Home Assistant Core", "installed_version": "2026.10.4",
			"latest_version": "2026.11.2", "in_progress": false, "update_percentage": null,
			"release_summary": "A made-up update for the demo.", "supported_features": 29}},
		"event.front_doorbell": {"state": _iso(now - 1500), "attributes": {
			"friendly_name": "Front Doorbell", "device_class": "doorbell", "event_type": "ring", "event_types": ["ring"]}},
		"scene.movie_night": {"state": "unknown", "attributes": {"friendly_name": "Movie Night"}},
		"script.good_night": {"state": "off", "attributes": {"friendly_name": "Good Night"}},
		"input_boolean.guest_mode": {"state": "off", "attributes": {"friendly_name": "Guest Mode"}},
		"input_select.house_mode": {"state": "Home", "attributes": {"friendly_name": "House Mode", "options": ["Home", "Away", "Night", "Vacation"]}},
		"sun.sun": {"state": "above_horizon", "attributes": {
			"friendly_name": "Sun", "elevation": 22.0, "azimuth": 170.0, "rising": false,
			"next_setting": _iso(now + 4 * 3600), "next_rising": _iso(now + 16 * 3600)}},

		# People and places
		"zone.home": {"state": "0", "attributes": {"friendly_name": "Home", "latitude": HOME.x, "longitude": HOME.y,
			"radius": HOME_RADIUS, "icon": "mdi:home", "passive": false}},
		"person.alex": {"state": "home", "attributes": {"friendly_name": "Alex", "gps_accuracy": 20, "source": "device_tracker.alex_phone"}},
		"person.sam": {"state": "home", "attributes": {"friendly_name": "Sam", "gps_accuracy": 35, "source": "device_tracker.sam_phone"}},
		"device_tracker.alex_phone": {"state": "home", "attributes": {"friendly_name": "Alex's Phone", "source_type": "gps", "gps_accuracy": 20, "battery_level": 74}},
		"device_tracker.sam_phone": {"state": "home", "attributes": {"friendly_name": "Sam's Phone", "source_type": "gps", "gps_accuracy": 35, "battery_level": 41}},
	}

	for id in ZONES:
		states[id] = {"state": "0", "attributes": {"friendly_name": ZONES[id][0],
			"latitude": ZONES[id][1].x, "longitude": ZONES[id][1].y, "radius": ZONES[id][2], "passive": false}}

	return states

## Devices for the Widgets panel. Entities that belong to no device are grouped per
## domain, like the Home Assistant adapter does.
func _devices() -> Array:
	var list = [
		_device("living_room_ceiling", "Living Room Ceiling Light", "Living Room", "Color bulb", ["light.living_room_ceiling"]),
		_device("living_room_floor_lamp", "Living Room Floor Lamp", "Living Room", "Dimmable bulb", ["light.living_room_floor_lamp"]),
		_device("living_room_speaker", "Living Room Speaker", "Living Room", "Smart speaker", ["media_player.living_room_speaker"]),
		_device("living_room_thermostat", "Living Room Thermostat", "Living Room", "Thermostat", ["climate.living_room_thermostat"]),
		_device("living_room_climate_sensor", "Living Room Climate Sensor", "Living Room", "Temperature & humidity sensor", ["sensor.living_room_temperature", "sensor.living_room_humidity"]),
		_device("living_room_blinds", "Living Room Blinds", "Living Room", "Blind motor", ["cover.living_room_blinds"]),
		_device("balcony_door", "Balcony Door Sensor", "Living Room", "Contact sensor", ["binary_sensor.balcony_door"]),
		_device("front_door_lock", "Front Door Lock", "Living Room", "Smart lock", ["lock.front_door", "event.front_doorbell"]),
		_device("robot_vacuum", "Robot Vacuum", "Living Room", "Robot vacuum", ["vacuum.robot_vacuum"]),
		_device("kitchen_spots", "Kitchen Spots", "Kitchen", "Dimmable spots", ["light.kitchen_spots"]),
		_device("coffee_machine", "Coffee Machine", "Kitchen", "Smart plug", ["switch.coffee_machine"]),
		_device("kitchen_climate_sensor", "Kitchen Climate Sensor", "Kitchen", "Temperature & humidity sensor", ["sensor.kitchen_temperature", "sensor.kitchen_humidity"]),
		_device("dishwasher", "Dishwasher", "Kitchen", "Dishwasher", ["sensor.dishwasher_status"]),
		_device("kitchen_window", "Kitchen Window Sensor", "Kitchen", "Contact sensor", ["binary_sensor.kitchen_window"]),
		_device("bedside_lamp", "Bedside Lamp", "Bedroom", "Color bulb", ["light.bedside_lamp"]),
		_device("bedroom_curtains", "Bedroom Curtains", "Bedroom", "Curtain motor", ["cover.bedroom_curtains"]),
		_device("bedroom_climate_sensor", "Bedroom Climate Sensor", "Bedroom", "Temperature & humidity sensor", ["sensor.bedroom_temperature", "sensor.bedroom_humidity"]),
		_device("bedroom_humidifier", "Bedroom Humidifier", "Bedroom", "Humidifier", ["humidifier.bedroom_humidifier"]),
		_device("bathroom_mirror", "Bathroom Mirror Light", "Bathroom", "Dimmable bulb", ["light.bathroom_mirror"]),
		_device("bathroom_fan", "Bathroom Fan", "Bathroom", "Fan", ["fan.bathroom_fan"]),
		_device("bathroom_climate_sensor", "Bathroom Climate Sensor", "Bathroom", "Temperature & humidity sensor", ["sensor.bathroom_temperature", "sensor.bathroom_humidity"]),
		_device("boiler", "Boiler", "Bathroom", "Water heater", ["water_heater.boiler"]),
		_device("alarm", "Home Alarm", null, "Alarm panel", ["alarm_control_panel.home_alarm"]),
		_device("alex_phone", "Alex's Phone", null, "Phone", ["device_tracker.alex_phone"]),
		_device("sam_phone", "Sam's Phone", null, "Phone", ["device_tracker.sam_phone"]),
		_device("home_assistant", "Home Assistant", null, "Home Assistant", ["update.home_assistant_core"]),
	]

	var in_device = {}
	for device in list:
		for entity in device.entities:
			in_device[entity.id] = true

	var groups = {}
	for id in entities:
		if in_device.has(id):
			continue
		var domain = id.split(".")[0]
		if not groups.has(domain):
			groups[domain] = []
		groups[domain].append({"id": id, "name": entities[id].attributes.get("friendly_name", id)})

	for domain in groups:
		list.append({"id": "other." + domain, "name": domain.replace("_", " ").capitalize(), "area": null,
			"manufacturer": null, "model": null, "entities": groups[domain]})

	return list

func _device(id: String, name: String, area, model: String, entity_ids: Array) -> Dictionary:
	return {
		"id": "demo_" + id,
		"name": name,
		"area": area,
		"manufacturer": "Demo",
		"model": model,
		"entities": entity_ids.map(func(entity_id): return {"id": entity_id, "name": entities[entity_id].attributes.get("friendly_name", entity_id)}),
	}

static func _sensor(name: String, value: String, unit: String, device_class: String) -> Dictionary:
	return {"state": value, "attributes": {"friendly_name": name, "unit_of_measurement": unit,
		"device_class": device_class, "state_class": "measurement"}}

## UTC timestamp like Home Assistant's last_changed.
static func _iso(unix: float) -> String:
	return Time.get_datetime_string_from_unix_time(int(unix)) + "+00:00"

## Local wall-clock time like calendar start_time ("2026-11-20 10:00:00").
static func _local(unix: float) -> String:
	return Time.get_datetime_string_from_unix_time(int(unix) + int(Time.get_time_zone_from_system().bias) * 60, true)
