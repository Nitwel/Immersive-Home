extends "res://test/ui/ui_gallery.gd"
## Desktop gallery for every entity widget EntityFactory can create.
##
## Replaces the Home Assistant adapter with MockHomeApi, so the entities get
## realistic states without a server and clicking them runs a simulated service
## call (toggle lights, start timers, skip tracks, ...). Camera, controls and
## command line flags are the same as the UI gallery (see ui_gallery.gd), plus:
##
##   U                 - push a random state update to every entity (watch_state path)
##   --edge-cases      - add a cell with malformed/minimal states to find crashes
##   --frame-stats     - print the longest frames on exit, to spot main thread stalls
##                       (e.g. while maps load)
##
## The last cell lists Home Assistant domains EntityFactory does not support yet.

const MockHomeApi = preload ("./mock_home_api.gd")
const MapOverview = preload ("res://content/system/map_overview/map_overview.gd")

## Common Home Assistant entity domains, used to report which ones have no widget yet.
const HA_DOMAINS = [
	"air_quality", "alarm_control_panel", "assist_satellite", "automation", "binary_sensor",
	"button", "calendar", "camera", "climate", "conversation", "counter", "cover", "date",
	"datetime", "device_tracker", "event", "fan", "group", "humidifier", "image", "input_boolean",
	"input_button", "input_datetime", "input_number", "input_select", "input_text", "lawn_mower",
	"light", "lock", "media_player", "notify", "number", "person", "remote", "scene", "script",
	"select", "sensor", "siren", "stt", "sun", "switch", "text", "time", "timer", "todo", "tts",
	"update", "vacuum", "valve", "wake_word", "water_heater", "weather", "zone",
]

var mock: MockHomeApi
var _frame_times := PackedFloat32Array()
var _last_frame_usec := 0

func _ready():
	_install_mock()
	super()

func _process(_delta):
	if not _args.has("frame-stats"):
		return
	# Wall clock between frames, so a stall shows even if the engine caps delta.
	var now = Time.get_ticks_usec()
	if _last_frame_usec > 0:
		_frame_times.append((now - _last_frame_usec) / 1000.0)
	_last_frame_usec = now

func _exit_tree():
	if _frame_times.is_empty():
		return
	var sorted = Array(_frame_times)
	sorted.sort()
	sorted.reverse()
	var slow = []
	var elapsed = 0.0
	for ms in _frame_times:
		elapsed += ms
		if ms > 50.0:
			slow.append("%.0f ms at %.1f s" % [ms, elapsed / 1000.0])
	print("frame-stats: %d frames, longest %s ms; over 50 ms: %s" % [
		_frame_times.size(), ", ".join(sorted.slice(0, 5).map(func(ms): return "%.0f" % ms)), ", ".join(slow) if not slow.is_empty() else "none"])

func _install_mock():
	# Drop a real adapter HomeApi may have started from the saved settings.
	HomeApi.reconnect_timer.stop()
	if HomeApi.api != null:
		HomeApi.remove_child(HomeApi.api)
		HomeApi.api.queue_free()

	mock = MockHomeApi.new(_initial_states())
	mock.name = "MockHomeApi"
	HomeApi.api = mock
	HomeApi.add_child(mock)
	mock.on_call.connect(func(entity, state, attributes):
		status_label.text = "%s → %s %s" % [entity, state, "" if attributes.is_empty() else str(attributes)]
	)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_U \
			and not (EventSystem.get_focused() is Input3D):
		_push_random_updates()
		return
	super(event)

# ---------------------------------------------------------------------------
# Mock states, shaped like Home Assistant's subscribe_entities payload
# ---------------------------------------------------------------------------

func _initial_states() -> Dictionary:
	var now = Time.get_unix_time_from_system()
	return {
		"light.rgb": {"state": "on", "attributes": {
			"friendly_name": "RGB light", "brightness": 200, "rgb_color": [255, 120, 40],
			"supported_color_modes": ["rgb"], "color_mode": "rgb",
			"effect_list": ["None", "Rainbow", "Candle", "Strobe"], "effect": "Candle"}},
		"light.dimmable": {"state": "on", "attributes": {
			"friendly_name": "Dimmable light", "brightness": 90, "supported_color_modes": ["brightness"]}},
		"light.onoff": {"state": "off", "attributes": {
			"friendly_name": "On/off light", "supported_color_modes": ["onoff"]}},
		"light.settings": {"state": "on", "attributes": {
			"friendly_name": "Light settings", "brightness": 255, "rgb_color": [120, 180, 255],
			"supported_color_modes": ["rgb"], "effect_list": ["None", "Rainbow"], "effect": "None"}},

		"switch.on": {"state": "on", "attributes": {"friendly_name": "Switch on"}},
		"switch.off": {"state": "off", "attributes": {"friendly_name": "Switch off"}},
		"switch.unavailable": {"state": "unavailable", "attributes": {"friendly_name": "Switch unavailable"}},

		"sensor.temperature": {"state": "21.4", "attributes": {
			"friendly_name": "Temperature", "unit_of_measurement": "°C", "device_class": "temperature",
			"state_class": "measurement"}},
		"sensor.text": {"state": "Dishwasher running", "attributes": {"friendly_name": "Status"}},
		"sensor.unavailable": {"state": "unavailable", "attributes": {
			"friendly_name": "Humidity", "unit_of_measurement": "%", "device_class": "humidity"}},

		"binary_sensor.on": {"state": "on", "attributes": {"friendly_name": "Window open", "device_class": "window"}},
		"binary_sensor.off": {"state": "off", "attributes": {"friendly_name": "Motion", "device_class": "motion"}},
		"binary_sensor.unavailable": {"state": "unavailable", "attributes": {"friendly_name": "Door"}},

		"media_player.playing": {"state": "playing", "attributes": {
			"friendly_name": "Living room speaker", "media_title": "Northern Lights", "media_artist": "The Placeholders",
			"volume_level": 0.35, "_tracks": [["Northern Lights", "The Placeholders"], ["Second Song", "Test Artist"], ["Third One", "Mock Band"]]}},
		"media_player.paused": {"state": "paused", "attributes": {
			"friendly_name": "Kitchen speaker", "media_title": "Paused track", "media_artist": "Someone", "volume_level": 0.6}},
		"media_player.off": {"state": "off", "attributes": {"friendly_name": "TV"}},
		"media_player.settings": {"state": "paused", "attributes": {"friendly_name": "Settings player", "volume_level": 0.5}},

		"camera.idle": {"state": "idle", "attributes": {"friendly_name": "Front door"}},
		"camera.unavailable": {"state": "unavailable", "attributes": {"friendly_name": "Garage"}},
		"camera.settings": {"state": "idle", "attributes": {"friendly_name": "Camera settings"}},

		"button.text": {"state": "unknown", "attributes": {"friendly_name": "Restart"}},
		"button.icon": {"state": "unknown", "attributes": {"friendly_name": "icon:power_settings_new"}},

		"number.percent": {"state": "40", "attributes": {
			"friendly_name": "Fan speed", "min": 0, "max": 100, "step": 1, "unit_of_measurement": "%"}},
		"number.float": {"state": "21.5", "attributes": {
			"friendly_name": "Target temp", "min": 15, "max": 30, "step": 0.5, "unit_of_measurement": "°C"}},

		"timer.idle": {"state": "idle", "attributes": {"friendly_name": "Pasta", "duration": "0:10:00", "remaining": "0:10:00"}},
		"timer.active": {"state": "active", "attributes": {
			"friendly_name": "Laundry", "duration": "1:30:00", "remaining": "1:30:00",
			"finishes_at": Time.get_datetime_string_from_unix_time(int(now + 2723)) + "+00:00"}},
		"timer.paused": {"state": "paused", "attributes": {"friendly_name": "Oven", "duration": "0:45:00", "remaining": "0:12:34"}},

		"weather.sunny": _weather("sunny", 24.5, 40),
		"weather.rainy": _weather("rainy", 12.0, 92),
		"weather.lightning": _weather("lightning-rainy", 18.3, 85),
		"weather.snowy": _weather("snowy", -2.0, 70),

		# Domains reusing an existing widget
		"input_boolean.guest_mode": {"state": "on", "attributes": {"friendly_name": "Guest mode"}},
		"automation.night_lights": {"state": "off", "attributes": {"friendly_name": "Night lights automation"}},
		"input_number.volume": {"state": "30", "attributes": {"friendly_name": "Volume", "min": 0, "max": 50, "step": 5}},
		"input_button.doorbell": {"state": "unknown", "attributes": {"friendly_name": "Ring doorbell"}},
		"scene.movie": {"state": "unknown", "attributes": {"friendly_name": "Movie time"}},
		"script.good_night": {"state": "off", "attributes": {"friendly_name": "Good night"}},
		"counter.coffees": {"state": "3", "attributes": {"friendly_name": "Coffees today", "step": 1}},

		"select.fan_mode": {"state": "medium", "attributes": {"friendly_name": "Fan mode", "options": ["low", "medium", "high", "auto"]}},
		"input_select.house_mode": {"state": "Home", "attributes": {"friendly_name": "House mode", "options": ["Home", "Away", "Night", "Vacation"]}},
		"select.unavailable": {"state": "unavailable", "attributes": {"friendly_name": "Unavailable select", "options": []}},

		"climate.living_room": {"state": "heat", "attributes": {
			"friendly_name": "Living room", "hvac_modes": ["off", "heat", "cool", "auto"], "hvac_action": "heating",
			"current_temperature": 20.4, "temperature": 21.5, "min_temp": 7, "max_temp": 30, "target_temp_step": 0.5}},
		"climate.range": {"state": "heat_cool", "attributes": {
			"friendly_name": "Office", "hvac_modes": ["off", "heat_cool"], "hvac_action": "idle",
			"current_temperature": 22.1, "target_temp_low": 20, "target_temp_high": 24, "min_temp": 10, "max_temp": 30}},
		"climate.off": {"state": "off", "attributes": {
			"friendly_name": "Bedroom", "hvac_modes": ["off", "heat"], "hvac_action": "off",
			"current_temperature": 18.0, "temperature": null}},

		"lock.front_door": {"state": "locked", "attributes": {"friendly_name": "Front door"}},
		"lock.garage": {"state": "unlocked", "attributes": {"friendly_name": "Garage"}},
		"lock.jammed": {"state": "jammed", "attributes": {"friendly_name": "Back door"}},

		"text.message": {"state": "Hello from Home Assistant", "attributes": {"friendly_name": "Display message", "min": 0, "max": 100, "mode": "text"}},
		"input_text.note": {"state": "", "attributes": {"friendly_name": "Note", "min": 0, "max": 255}},

		"date.birthday": {"state": "2026-03-14", "attributes": {"friendly_name": "Birthday"}},
		"time.alarm": {"state": "06:45:00", "attributes": {"friendly_name": "Alarm"}},
		"datetime.next_service": {"state": "2026-12-01T08:30:00+00:00", "attributes": {"friendly_name": "Next service"}},
		"date.unknown": {"state": "unknown", "attributes": {"friendly_name": "Unset date"}},

		# Made-up positions around a public landmark (Brandenburg Gate, Berlin)
		"zone.home": {"state": "1", "attributes": {"friendly_name": "Home", "latitude": 52.5163, "longitude": 13.3777, "radius": 120, "icon": "mdi:home"}},
		"person.alice": {"state": "home", "attributes": {"friendly_name": "Alice Example", "latitude": 52.5164, "longitude": 13.3781, "gps_accuracy": 25, "source": "device_tracker.alice_phone"}},
		"person.bob": {"state": "not_home", "attributes": {"friendly_name": "Bob", "latitude": 52.5215, "longitude": 13.4110, "gps_accuracy": 60, "source": "device_tracker.bob_phone"}},
		"device_tracker.work_phone": {"state": "Work", "attributes": {"friendly_name": "Work phone", "source_type": "gps", "latitude": 52.5096, "longitude": 13.3760, "gps_accuracy": 15, "battery_level": 80}},
		"device_tracker.router": {"state": "home", "attributes": {"friendly_name": "Laptop", "source_type": "router", "ip": "192.0.2.10"}},
		"person.no_location": {"state": "not_home", "attributes": {"friendly_name": "Carol"}},
		# Made-up position near a public mountain (Zugspitze) to test the height map
		"device_tracker.hiker": {"state": "not_home", "attributes": {"friendly_name": "Hiking watch", "source_type": "gps", "latitude": 47.4211, "longitude": 10.9853, "gps_accuracy": 30}},
	}

func _weather(state: String, temperature: float, humidity: int) -> Dictionary:
	return {"state": state, "attributes": {
		"friendly_name": "Weather " + state, "temperature": temperature, "temperature_unit": "°C",
		"humidity": humidity, "pressure": 1013, "wind_speed": 12.0}}

const WEATHER_STATES = ["clear-night", "cloudy", "fog", "hail", "lightning", "lightning-rainy", "partlycloudy",
	"pouring", "rainy", "snowy", "snowy-rainy", "sunny", "windy", "windy-variant", "exceptional"]

func _push_random_updates():
	mock.update_entity("sensor.temperature", "%.1f" % randf_range(16, 28))
	mock.update_entity("sensor.text", ["Idle", "Dishwasher running", "Washing done"].pick_random())
	mock.update_entity("binary_sensor.on", ["on", "off"].pick_random())
	mock.update_entity("binary_sensor.off", ["on", "off"].pick_random())
	mock.update_entity("number.percent", str(randi_range(0, 100)))
	mock.update_entity("switch.off", ["on", "off"].pick_random())
	for id in ["weather.sunny", "weather.rainy", "weather.lightning", "weather.snowy"]:
		mock.update_entity(id, WEATHER_STATES.pick_random(), {"temperature": snappedf(randf_range(-5, 30), 0.1), "humidity": randi_range(20, 99)})
	mock.update_entity("light.dimmable", "on", {"brightness": randi_range(10, 255)})
	var bob = mock.entities["person.bob"].attributes
	mock.update_entity("person.bob", "not_home", {"latitude": bob.latitude + randf_range(-0.002, 0.002), "longitude": bob.longitude + randf_range(-0.003, 0.003)})
	status_label.text = "Pushed random state updates"
	await get_tree().create_timer(0.4).timeout
	_layout()

# ---------------------------------------------------------------------------
# Gallery content: one cell per entity type, one column per variant.
# Entities differ a lot in size and change size with their state, so cells are
# measured from the visible geometry once the states arrived (see _layout).
# ---------------------------------------------------------------------------

const PAD = 0.03
const GAP = 0.04
const TITLE_HEIGHT = 0.05
const CAPTION_HEIGHT = 0.035
const MAX_ROW_WIDTH = 2.4

var _laid_out := false

func _build_gallery():
	_entity_cell("Light", [["RGB + effects", "light.rgb"], ["Dimmable", "light.dimmable"],
		["On/off (off)", "light.onoff"], ["Settings open", "light.settings", true]])
	_entity_cell("Switch", [["On", "switch.on"], ["Off", "switch.off"], ["Unavailable", "switch.unavailable"]])
	_entity_cell("Sensor", [["Numeric", "sensor.temperature"], ["Text", "sensor.text"], ["Unavailable", "sensor.unavailable"]])
	_entity_cell("Binary sensor", [["On", "binary_sensor.on"], ["Off", "binary_sensor.off"], ["Unavailable", "binary_sensor.unavailable"]])
	_entity_cell("Media player", [["Playing", "media_player.playing"], ["Paused", "media_player.paused"],
		["Off", "media_player.off"], ["Settings open", "media_player.settings", true]])
	_entity_cell("Camera", [["No picture", "camera.idle"], ["Unavailable", "camera.unavailable"], ["Settings open", "camera.settings", true]])
	_entity_cell("Button", [["Text", "button.text"], ["Icon", "button.icon"]])
	_entity_cell("Number", [["0–100 %", "number.percent"], ["15–30 °C, step 0.5", "number.float"]])
	_entity_cell("Timer", [["Idle", "timer.idle"], ["Active", "timer.active"], ["Paused", "timer.paused"]])
	_entity_cell("Weather", [["Sunny", "weather.sunny"], ["Rainy", "weather.rainy"], ["Thunder", "weather.lightning"], ["Snowy", "weather.snowy"]])
	_entity_cell("Line chart", [["History of sensor.temperature", "sensor.temperature", false, "line_chart"],
		["Settings open", "sensor.temperature", true, "line_chart"]])

	_entity_cell("Climate", [["Single setpoint", "climate.living_room"], ["Range", "climate.range"], ["Off", "climate.off"]])
	_entity_cell("Lock", [["Locked", "lock.front_door"], ["Unlocked", "lock.garage"], ["Jammed", "lock.jammed"]])
	_entity_cell("Select", [["select", "select.fan_mode"], ["input_select", "input_select.house_mode"], ["Unavailable", "select.unavailable"]])
	_entity_cell("Text", [["text", "text.message"], ["input_text (empty)", "input_text.note"]])
	_entity_cell("Date and time", [["date", "date.birthday"], ["time", "time.alarm"], ["datetime (local)", "datetime.next_service"], ["Unknown", "date.unknown"]])
	_entity_cell("Person and tracker", [["Home", "person.alice"], ["Away", "person.bob"], ["GPS tracker in zone", "device_tracker.work_phone"],
		["Router tracker (no GPS)", "device_tracker.router"], ["No location", "person.no_location"]])
	_entity_cell("3D map", [["Home (houses)", "person.alice", false, null, {"map_3d": true}],
		["Away", "person.bob", false, null, {"map_3d": true}],
		["Mountains (height map)", "device_tracker.hiker", false, null, {"map_3d": true}],
		["Settings open", "device_tracker.work_phone", true, null, {"map_3d": true}]])
	_map_overview_cell()
	_entity_cell("Reused widgets", [["input_boolean", "input_boolean.guest_mode"], ["automation", "automation.night_lights"],
		["input_number", "input_number.volume"], ["input_button", "input_button.doorbell"], ["scene", "scene.movie"],
		["script", "script.good_night"], ["counter", "counter.coffees"]])

	if _args.has("edge-cases"):
		_add_edge_case_states()
		_entity_cell("Edge cases", [
			["Sensor w/o name", "sensor.no_name"], ["Light w/o attrs", "light.bare"],
			["Number unavailable", "number.bare"], ["Weather unknown", "weather.unknown"]])

	_add_unsupported_cell()

	_layout_when_ready()

## Entities still running _after_ready (fetching state, opening settings).
var _pending_entities := 0

func _layout_when_ready():
	# Wait for the entities, not a fixed time: the first frames can take longer than
	# any timer while shaders compile, and settings panels open a few frames in.
	while _pending_entities > 0:
		await get_tree().process_frame
	for i in 3:
		await get_tree().process_frame
	_layout()
	if _args.has("focus"):
		_focus_cell_by_name(_args["focus"])
	else:
		_focus_all()

## The floating "Map View" (content/system/map_overview), in 2D and 3D.
func _map_overview_cell():
	var cell = _new_cell("Map overview")
	for in_3d in [false, true]:
		var overview = MapOverview.new()
		overview.use_3d.value = in_3d
		cell.get_node("Content").add_child(overview)
		cell.get_meta("items").append({"node": overview, "caption": _caption("Map View (%s)" % ("3D" if in_3d else "2D"))})
		cell.get_node("Content").add_child(cell.get_meta("items")[-1].caption)

## Minimal states real Home Assistant can send; used to surface crashes.
func _add_edge_case_states():
	mock.entities["sensor.no_name"] = {"state": "5", "attributes": {}}
	mock.entities["light.bare"] = {"state": "on", "attributes": {}}
	mock.entities["number.bare"] = {"state": "unavailable", "attributes": {}}
	mock.entities["weather.unknown"] = {"state": "unknown", "attributes": {}}

## Creates an empty cell; [param items] are filled with {node, caption} pairs.
func _new_cell(cell_name: String) -> Node3D:
	var cell = Node3D.new()
	cell.name = cell_name
	cells_root.add_child(cell)
	cells.append(cell)

	var frame = MeshInstance3D.new()
	frame.name = "Frame"
	frame.mesh = QuadMesh.new()
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1, 1, 1, 0.04)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	frame.material_override = mat
	cell.add_child(frame)

	var title = Label3D.new()
	title.text = "%d  %s" % [cells.size(), cell_name]
	title.font_size = 24
	title.pixel_size = 0.001
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.modulate = Color(1, 1, 1, 0.6)
	title.position = Vector3(0.02, -0.025, 0)
	cell.add_child(title)

	var content = Node3D.new()
	content.name = "Content"
	cell.add_child(content)

	cell.set_meta("items", [])
	cell.set_meta("size", Vector2(0.3, 0.2))
	return cell

func _caption(text: String) -> Label3D:
	var caption = Label3D.new()
	caption.text = text
	caption.font_size = 14
	caption.pixel_size = 0.001
	caption.modulate = Color(1, 1, 1, 0.6)
	return caption

## variants: [caption, entity_id, show_settings?, type?, options?]
func _entity_cell(cell_name: String, variants: Array):
	var cell = _new_cell(cell_name)
	var content = cell.get_node("Content")

	for variant in variants:
		var entity = EntityFactory.create_entity(variant[1], variant[3] if variant.size() > 3 else null)
		if entity != null and variant.size() > 4:
			entity.set_options(variant[4]) # e.g. {"map_3d": true}
		var caption = _caption(variant[0] + "\n" + variant[1] if entity != null else variant[0] + "\n(not created)")
		content.add_child(caption)

		if entity == null:
			cell.get_meta("items").append({"node": caption, "caption": null})
			continue

		content.add_child(entity)
		cell.get_meta("items").append({"node": entity, "caption": caption})
		_after_ready(entity, variant.size() > 2 and variant[2])

func _after_ready(entity, open_settings: bool):
	_pending_entities += 1
	await get_tree().process_frame
	# CameraFollower tracks App.camera (the XR headset), which doesn't exist here.
	# Opening settings enables it, so switch it off right away and once more after
	# the reactive effects ran.
	# physics_frame fires before EventSystem's _physics_process sends the slow tick.
	if open_settings:
		entity.show_settings.value = true
		await get_tree().physics_frame
	if entity.camera_follower != null:
		entity.camera_follower.enabled = false
	_pending_entities -= 1

func _add_unsupported_cell():
	var unsupported = HA_DOMAINS.filter(func(domain): return not EntityFactory.is_supported(domain))
	var supported = EntityFactory.SUPPORTED_DOMAINS

	var cell = _new_cell("Unsupported domains")
	var label = Label3D.new()
	label.text = "Supported (%d):\n%s\n\nNot supported yet (%d):\n%s" % [
		supported.size(), _wrap(supported, 5), unsupported.size(), _wrap(unsupported, 5)]
	label.font_size = 16
	label.pixel_size = 0.001
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.modulate = Color(1, 1, 1, 0.85)
	cell.get_node("Content").add_child(label)
	cell.get_meta("items").append({"node": label, "caption": null})

func _wrap(items: Array, per_line: int) -> String:
	var lines = []
	for i in range(0, items.size(), per_line):
		lines.append(", ".join(items.slice(i, i + per_line)))
	return ",\n".join(lines)

# ---------------------------------------------------------------------------
# Layout
# ---------------------------------------------------------------------------

## Visible bounds of [param node] in the coordinates of [param space].
func _bounds(node: Node3D, space: Node3D) -> AABB:
	var result = null
	var stack: Array = [node]
	while not stack.is_empty():
		var n = stack.pop_back()
		if n is Node3D and not n.is_visible_in_tree():
			continue
		if n is VisualInstance3D:
			var box: AABB = n.get_aabb()
			if box.size.length() > 0.0001 and box.size.length() < 5.0:
				box = (space.global_transform.affine_inverse() * n.global_transform) * box
				result = box if result == null else result.merge(box)
		stack.append_array(n.get_children())
	return result if result != null else AABB(Vector3.ZERO, Vector3(0.05, 0.05, 0))

func _layout():
	var x = 0.0
	var y = 0.0
	var row_height = 0.0

	for cell in cells:
		var content: Node3D = cell.get_node("Content")
		content.position = Vector3.ZERO
		var items: Array = cell.get_meta("items")

		# Lay the variants out left to right, aligned on their tops.
		var cursor = PAD
		var top = -INF
		var bottom = INF
		var boxes = []
		for item in items:
			item.node.position = Vector3.ZERO
			var box = _bounds(item.node, content)
			var width = box.size.x
			if item.caption != null:
				var text_size = item.caption.font.get_multiline_string_size(item.caption.text, HORIZONTAL_ALIGNMENT_CENTER, -1, item.caption.font_size) if item.caption.font != null \
					else ThemeDB.fallback_font.get_multiline_string_size(item.caption.text, HORIZONTAL_ALIGNMENT_CENTER, -1, item.caption.font_size)
				width = max(width, text_size.x * item.caption.pixel_size)
			# Centre the entity in its column (the column may be wider for the caption).
			item.node.position.x = cursor + (width - box.size.x) / 2.0 - box.position.x
			box.position.x = cursor
			box.size.x = width
			boxes.append(box)
			cursor += box.size.x + GAP
			top = max(top, box.end.y)
			bottom = min(bottom, box.position.y)

		for i in items.size():
			if items[i].caption != null:
				items[i].caption.position = Vector3(boxes[i].get_center().x, bottom - CAPTION_HEIGHT / 2.0, 0.001)

		var has_captions = items.any(func(item): return item.caption != null)
		var size = Vector2(max(cursor - GAP + PAD, 0.3), TITLE_HEIGHT + (top - bottom) + (CAPTION_HEIGHT if has_captions else 0.0) + PAD)
		content.position.y = -TITLE_HEIGHT - top
		cell.set_meta("size", size)

		var frame: MeshInstance3D = cell.get_node("Frame")
		frame.mesh.size = size - Vector2(0.01, 0.01)
		frame.position = Vector3(size.x / 2.0, -size.y / 2.0, -0.02)

		if x > 0 and x + size.x > MAX_ROW_WIDTH:
			x = 0.0
			y -= row_height + 0.02
			row_height = 0.0
		cell.position = Vector3(x, y, 0)
		x += size.x + 0.02
		row_height = max(row_height, size.y)

	_laid_out = true

func _focus_all():
	if not _laid_out:
		return
	var box = Rect2()
	for cell in cells:
		var size: Vector2 = cell.get_meta("size")
		var rect = Rect2(Vector2(cell.position.x, cell.position.y - size.y), size)
		box = rect if box.size == Vector2.ZERO else box.merge(rect)
	_frame(Vector3(box.get_center().x, box.get_center().y, 0), box.size)

func _focus_cell(cell: Node3D):
	var size: Vector2 = cell.get_meta("size")
	_frame(cell.position + Vector3(size.x / 2.0, -size.y / 2.0, 0), size)

