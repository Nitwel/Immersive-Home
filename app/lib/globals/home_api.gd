extends Node
## Manages the connection to the home automation system and provides a unified interface to the different home automation systems.

const EntityGroups = preload ("res://lib/utils/entity_group.gd")
const HassWebSocket = preload ("res://lib/home_apis/hass_ws/hass.gd")
const VoiceAssistant = preload ("res://lib/home_apis/voice_handler.gd")
const FloorPlan = preload ("res://lib/utils/floor_plan.gd")
const Demo = preload ("res://lib/home_apis/demo/demo.gd")
const DemoHouse = preload ("res://lib/home_apis/demo/demo_house.gd")
const HouseStore = preload ("res://lib/stores/house.gd")

## Seconds to wait after the house changed before syncing the floor plan, moving
## things around saves the house many times in a row.
const FLOOR_PLAN_SYNC_DELAY = 2.0

const apis = {
	"hass_ws": HassWebSocket,
	"demo": Demo,
}

var groups = EntityGroups.new()

## Emitted when the connection to the home automation system is established
signal on_connect()

## Emitted when the connection to the home automation system is lost
signal on_disconnect()

## The current home automation system adapter
var api: Node
## Type of the current adapter, a key of [member apis]
var api_type := ""
var reconnect_timer := Timer.new()
var floor_plan_timer := Timer.new()
## JSON of the floor plan Home Assistant last stored, to skip unchanged syncs
var _synced_floor_plan := ""

func _ready():
	floor_plan_timer.wait_time = FLOOR_PLAN_SYNC_DELAY
	floor_plan_timer.one_shot = true
	add_child(floor_plan_timer)
	floor_plan_timer.timeout.connect(sync_floor_plan)

	Store.house.on_saved.connect(floor_plan_timer.start)
	Store.house.on_loaded.connect(floor_plan_timer.start)

	start()

	reconnect_timer.wait_time = 60
	reconnect_timer.one_shot = false
	reconnect_timer.autostart = true

	add_child(reconnect_timer)

	reconnect_timer.timeout.connect(func():
		if has_connected() == false:
			start()
	)

## Starts the adapter with the settings from the settings file
func start():
	var success = Store.settings.load_local()

	if success:
		start_adapter(Store.settings.state.type.to_lower(), Store.settings.state.url, Store.settings.state.token)

## Starts the adapter for the given type and url
func start_adapter(type: String, url: String, token: String):
	print("Starting adapter: %s" % type)
	if api != null:
		api.on_connect.disconnect(_on_connect)
		api.on_disconnect.disconnect(_on_disconnect)
		if api.has_signal("on_integration_ready"):
			api.on_integration_ready.disconnect(_on_integration_ready)
		remove_child(api)
		api.queue_free()
		api = null

	api_type = type
	_use_house_of(type)

	api = apis[type].new(url, token)
	add_child(api)

	api.on_connect.connect(_on_connect)
	api.on_disconnect.connect(_on_disconnect)
	if api.has_signal("on_integration_ready"):
		api.on_integration_ready.connect(_on_integration_ready)

func _on_connect():
	if is_demo()&&FileAccess.file_exists(HouseStore.DEMO_PATH) == false:
		_build_demo_house()

	Store.house.load_local()
	on_connect.emit()

## Returns true while the demo mode runs, with made-up devices instead of a real
## home automation system.
func is_demo() -> bool:
	return api_type == "demo"

## Starts the demo mode with a freshly built demo apartment around the user. It's
## remembered, so the app starts in demo mode until [method stop_demo] is called.
func start_demo():
	Store.settings.state.type = "DEMO"
	Store.settings.save_local()

	if FileAccess.file_exists(HouseStore.DEMO_PATH):
		DirAccess.remove_absolute(HouseStore.DEMO_PATH)

	start_adapter("demo", "", "")

## Leaves the demo mode and connects to the home automation system in the settings.
func stop_demo():
	Store.settings.state.type = "HASS_WS"
	Store.settings.save_local()

	start_adapter("hass_ws", Store.settings.state.url, Store.settings.state.token)

## The demo mode keeps its own house, so it never changes the real one.
func _use_house_of(type: String):
	var path = HouseStore.DEMO_PATH if type == "demo" else HouseStore.PATH

	if Store.house._save_path == path:
		return

	Store.house.use_save_path(path)

	# The rooms of the other house are still standing, take them down until the
	# new house is loaded on connect.
	if App.house != null&&App.house.is_inside_tree():
		App.house.update_house()

## Saves the demo apartment, built around where the user is standing.
func _build_demo_house():
	var origin = App.camera.global_transform if App.camera != null&&App.camera.is_inside_tree() else Transform3D()
	var house = DemoHouse.build(origin)

	for key in house:
		Store.house.state[key] = house[key]

	Store.house.save_local()

func _on_disconnect():
	on_disconnect.emit()

## A fresh connection: push the floor plan even if it didn't change, Home Assistant
## may have lost it or another headset may have replaced it in the meantime.
func _on_integration_ready():
	_synced_floor_plan = ""
	floor_plan_timer.stop()
	sync_floor_plan()

## Returns true if the adapter is connected to the home automation system
func has_connected():
	if api == null:
		return false
	return api.has_connected()

## Get a list of all devices
func get_devices():
	assert(has_connected(), "Not connected")
	return await api.get_devices()

## Get a single device by id
func get_device(id: String):
	assert(has_connected(), "Not connected")
	return await api.get_device(id)

## Returns the current state of an entity
func get_state(entity: String):
	assert(has_connected(), "Not connected")

	var group = groups.get_group(entity)

	if group != null:
		return await api.get_state(group[0])

	return await api.get_state(entity)

## Updates the state of the entity and returns the resulting state
func set_state(entity: String, state: Variant, attributes: Dictionary={}):
	assert(has_connected(), "Not connected")

	var group = groups.get_group(entity)

	if group != null:
		for group_entity in group:
			api.set_state(group_entity, state, attributes)

		return null

	return await api.set_state(entity, state, attributes)

## Watches the state and each time it changes, calls the callback with the changed state, returns a function to stop watching the state
func watch_state(entity: String, callback: Callable):
	assert(has_connected(), "Not connected")

	var group = groups.get_group(entity)

	if group != null:
		var unwatch_group = api.watch_state(group[0], callback)
		var unwatch_entity = api.watch_state(entity, callback)
		return func():
			unwatch_group.call()
			unwatch_entity.call()

	return api.watch_state(entity, callback)

## Stops every state watch whose callback belongs to [param target]. Entities call
## this when they are freed, so Home Assistant updates never reach a freed node.
func unwatch_owner(target: Object):
	if api != null&&api.has_method("unwatch_owner"):
		api.unwatch_owner(target)

## Returns true if the adapter has an integration in the home automation system
## allowing to send the room position of the headset.
func has_integration() -> bool:
	if has_connected() == false||api.has_method("has_integration") == false:
		return false

	return api.has_integration()

## Updates the room position of the headset in the home automation system
func update_room(room: String) -> void:
	if has_connected() == false||api.has_method("update_room") == false:
		return

	api.update_room(room)

## Sends the floor plan of the house (rooms, doors and the placed entities) to the
## home automation system, if it has an integration that stores it. Does nothing
## if the floor plan didn't change since the last sync.
func sync_floor_plan() -> void:
	if has_integration() == false||api.has_method("update_floor_plan") == false:
		return

	# Until the house is loaded the store holds no rooms, that would wipe the stored floor plan.
	if Store.house.is_loaded() == false:
		return

	var floor_plan = FloorPlan.build(Store.house.state)

	# A headset without a room setup shouldn't replace the floor plan of one that has it.
	if floor_plan.rooms.is_empty():
		return

	var json = JSON.stringify(floor_plan)

	if json == _synced_floor_plan:
		return

	if await api.update_floor_plan(floor_plan):
		_synced_floor_plan = json

## Returns the VoiceHandler if the adapter has a voice assistant
func get_voice_assistant() -> VoiceAssistant:
	assert(has_connected(), "Not connected")

	if api.has_method("get_voice_assistant") == false:
		return null

	return api.get_voice_assistant()

## Returns the items of a to-do list entity: [{uid, summary, status, due?}], or an
## empty array if the adapter can't list them.
func get_todo_items(entity_id: String) -> Array:
	if has_connected() == false||api.has_method("get_todo_items") == false:
		return []

	var items = await api.get_todo_items(entity_id)
	return items if items is Array else []

func get_history(entity_id, start, interval, end=null):
	assert(has_connected(), "Not connected")

	if api.has_method("get_history") == false:
		return null

	if groups.is_group(entity_id):
		return null

	return await api.get_history(entity_id, start, interval, end)

## Recorded states with attributes of several entities since [param start] (ISO
## time): {entity_id: [{state, attributes, time}]}, oldest first. Empty if the
## adapter has no history.
func get_state_history(entity_ids: Array, start: String, end=null) -> Dictionary:
	if has_connected() == false||api.has_method("get_state_history") == false:
		return {}

	return await api.get_state_history(entity_ids, start, end)

## Ids of all entities in [param domains], e.g. ["person", "device_tracker"].
func get_entity_ids(domains: Array) -> Array:
	if has_connected() == false||api.has_method("get_entity_ids") == false:
		return []

	return api.get_entity_ids(domains)

## Returns the HTTP(S) base URL of the home automation server, without a trailing slash,
## or an empty string if the adapter does not expose one.
func get_http_url() -> String:
	if api == null||api.has_method("get_http_url") == false:
		return ""

	return api.get_http_url()
