extends Node3D
## Checks the demo mode (lib/home_apis/demo) without a headset: starts the demo
## adapter, verifies the demo apartment and devices fit together, runs the
## simulation and creates every placed widget. Prints "demo_check: PASS" or the
## failures, then quits.
##
## Only touches user://demo_house.json, which it removes again. With
## [code]-- --screenshot=<path.png>[/code] (not headless) it also renders the
## apartment as the Map View's dollhouse and saves it.

const DemoHouse = preload ("res://lib/home_apis/demo/demo_house.gd")
const Demo = preload ("res://lib/home_apis/demo/demo.gd")
const HouseStore = preload ("res://lib/stores/house.gd")
const Dollhouse = preload ("res://content/system/miniature/dollhouse.gd")

## Same limit the wall mesh uses to decide a door is in a wall.
const DOOR_IN_WALL = 0.02

var failures: Array[String] = []

func _ready():
	var args = {}
	for arg in OS.get_cmdline_user_args():
		var parts = arg.trim_prefix("--").split("=", true, 1)
		args[parts[0]] = parts[1] if parts.size() > 1 else ""

	_check_layout(DemoHouse.build(Transform3D(Basis(Vector3.UP, 0.7), Vector3(3, 1.7, -2))), "turned")
	_check_layout(DemoHouse.build(Transform3D()), "origin")

	HomeApi.reconnect_timer.stop()
	if FileAccess.file_exists(HouseStore.DEMO_PATH):
		DirAccess.remove_absolute(HouseStore.DEMO_PATH)

	HomeApi.start_adapter("demo", "", "")
	await HomeApi.on_connect

	_expect(HomeApi.is_demo(), "HomeApi.is_demo() while the demo runs")
	_expect(Store.house._save_path == HouseStore.DEMO_PATH, "the house is saved to the demo file")
	_expect(FileAccess.file_exists(HouseStore.DEMO_PATH), "the demo house was saved")

	var state = Store.house.state
	_expect(state.rooms.size() == DemoHouse.ROOMS.size(), "%d rooms loaded" % state.rooms.size())
	_expect(state.doors.size() == DemoHouse.DOORS.size(), "%d doors loaded" % state.doors.size())
	_expect(state.entities.size() == DemoHouse.ENTITIES.size(), "%d entities loaded" % state.entities.size())

	var api: Demo = HomeApi.api
	_check_entities(api, state)
	await _check_devices(api, state)
	await _check_simulation(api)
	await _check_history(api)
	await _check_widgets(state)

	if args.has("screenshot"):
		await _screenshot(state, args["screenshot"])

	DirAccess.remove_absolute(HouseStore.DEMO_PATH)

	if failures.is_empty():
		print("demo_check: PASS")
	else:
		print("demo_check: FAIL\n  - " + "\n  - ".join(failures))
	get_tree().quit(0 if failures.is_empty() else 1)

func _expect(condition: bool, what: String):
	if not condition:
		failures.append(what)

## Rooms don't overlap, doors sit in both rooms' walls, widgets are inside their room.
func _check_layout(house: Dictionary, label: String):
	var polygons = {}
	for room in house.rooms:
		polygons[room.name] = PackedVector2Array(room.corners)

	for a in polygons:
		for b in polygons:
			if a < b:
				_expect(Geometry2D.intersect_polygons(polygons[a], polygons[b]).is_empty(), "%s: %s and %s overlap" % [label, a, b])

	for door in house.doors:
		for side in [[door.room1, "room1"], [door.room2, "room2"]]:
			for point in [door[side[1] + "_position1"], door[side[1] + "_position2"]]:
				var distance = _distance_to_outline(Vector2(point.x, point.z), polygons[side[0]])
				_expect(distance < DOOR_IN_WALL, "%s: door %s-%s is %.3f m from %s's wall" % [label, door.room1, door.room2, distance, side[0]])

	for entity in house.entities:
		var point = Vector2(entity.position.x, entity.position.z)
		_expect(Geometry2D.is_point_in_polygon(point, polygons[entity.room]), "%s: %s is outside %s" % [label, entity.id, entity.room])
		_expect(entity.position.y > 0.3 and entity.position.y < DemoHouse.HEIGHT, "%s: %s height %.2f" % [label, entity.id, entity.position.y])

static func _distance_to_outline(point: Vector2, polygon: PackedVector2Array) -> float:
	var best = INF
	for i in polygon.size():
		var closest = Geometry2D.get_closest_point_to_segment(point, polygon[i], polygon[(i + 1) % polygon.size()])
		best = min(best, closest.distance_to(point))
	return best

func _check_entities(api: Demo, state):
	for entity in state.entities:
		_expect(api.entities.has(entity.id), "placed %s has a state" % entity.id)
		_expect(EntityFactory.is_supported(entity.id), "placed %s has a widget" % entity.id)

func _check_devices(api: Demo, state):
	var devices = await HomeApi.get_devices()
	_expect(devices.size() > 10, "%d devices listed" % devices.size())

	var room_names = state.rooms.map(func(room): return room.name)
	var listed = {}
	for device in devices:
		if device.area != null:
			_expect(room_names.has(device.area), "device %s is in a room that exists (%s)" % [device.name, device.area])
		for entity in device.entities:
			_expect(api.entities.has(entity.id), "device entity %s has a state" % entity.id)
			listed[entity.id] = true

	for id in api.entities:
		_expect(listed.has(id), "%s is listed in a device" % id)

func _check_simulation(api: Demo):
	await HomeApi.set_state("light.kitchen_spots", "on")
	_expect((await HomeApi.get_state("light.kitchen_spots")).state == "on", "turning a light on works")

	var updates = [0]
	HomeApi.watch_state("sensor.bedroom_temperature", func(_new_state): updates[0] += 1)

	for i in 50:
		api._tick()

	_expect(updates[0] > 0, "sensors send updates")
	for id in api._baselines:
		var value = float(api.entities[id].state)
		var humidity = api.entities[id].attributes.device_class == "humidity"
		_expect(value >= (20.0 if humidity else 14.0) and value <= (95.0 if humidity else 30.0), "%s stays plausible (%s)" % [id, value])

	for person in Demo.ROUTES:
		var attributes = api.entities[person].attributes
		var location = Vector2(attributes.latitude, attributes.longitude)
		_expect(Demo._meters(location, Demo.HOME) < 5000.0, "%s stays in the city" % person)
		_expect(api.entities[person].state == api.entities[Demo.ROUTES[person].tracker].state, "%s and their phone agree" % person)

	# Over a whole period everyone leaves home, visits a zone and comes back.
	for person in Demo.ROUTES:
		var route = Demo.ROUTES[person]
		var states = {}
		for i in 200:
			states[Demo._zone_state(Demo.route_position(route, i * route.period / 200.0))] = true
		_expect(states.has("home") and states.has("not_home"), "%s leaves home and returns (%s)" % [person, states.keys()])
		_expect(states.size() >= 3, "%s passes a zone (%s)" % [person, states.keys()])

func _check_history(api: Demo):
	var start = Time.get_datetime_string_from_unix_time(int(Time.get_unix_time_from_system() - 6 * 3600)) + "Z"
	var history = await HomeApi.get_state_history(["person.sam", "sensor.kitchen_temperature"], start)
	_expect(history.has("person.sam") and history["person.sam"].size() > 100, "person history has positions")
	_expect(history.has("sensor.kitchen_temperature"), "other entities still get history")

	if history.has("person.sam"):
		var last = history["person.sam"][-1].attributes
		var now = api.entities["person.sam"].attributes
		var gap = Demo._meters(Vector2(last.latitude, last.longitude), Vector2(now.latitude, now.longitude))
		_expect(gap < 500.0, "the path ends close to where Sam is now (%.0f m)" % gap)

## Creates every placed widget, like the house does, so script errors show up.
func _check_widgets(state):
	var root = Node3D.new()
	add_child(root)
	for entity in state.entities:
		var widget = EntityFactory.create_entity(entity.id, entity.get("interface", null))
		_expect(widget != null, "widget for %s was created" % entity.id)
		if widget != null:
			root.add_child(widget)
	await get_tree().create_timer(1.5).timeout
	root.queue_free()

func _screenshot(state, path: String):
	var dollhouse = Dollhouse.new()
	add_child(dollhouse)
	dollhouse.build(state.rooms, state.doors, state.entities)
	dollhouse.set_view(1.0, 0.05, null)

	var camera = Camera3D.new()
	add_child(camera)
	camera.position = Vector3(1.2, 9.5, 4.5)
	camera.look_at(Vector3(1.2, 0, -1.6))
	camera.current = true

	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-60, 30, 0)
	add_child(light)

	await get_tree().create_timer(2.0).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
	print("demo_check: saved ", path)
