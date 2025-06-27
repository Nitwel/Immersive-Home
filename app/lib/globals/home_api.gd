extends Node
## Manages the connection to the home automation system and provides a unified interface to the different home automation systems.

const EntityGroups = preload ("res://lib/utils/entity_group.gd")
const HassWebSocket = preload ("res://lib/home_apis/hass_ws/hass.gd")
const VoiceAssistant = preload ("res://lib/home_apis/voice_handler.gd")

const apis = {
	"hass_ws": HassWebSocket
}

var groups = EntityGroups.new()

## Emitted when the connection to the home automation system is established
signal on_connect()

## Emitted when the connection to the home automation system is lost
signal on_disconnect()

## The current home automation system adapter
var api: Node
var reconnect_timer := Timer.new()

#var enablestarthassadapter = true
var enablestarthassadapter = false
func _ready():
	#Dstart() 
	var success = Store.settings.load_local()
	if success and enablestarthassadapter:
		start_adapter(Store.settings.state.type.to_lower(), Store.settings.state.url, Store.settings.state.token)
	Store.house.load_local()


	#return   # disabled hass watchdog
	
	reconnect_timer.wait_time = 60
	reconnect_timer.one_shot = false
	reconnect_timer.autostart = true
	add_child(reconnect_timer)
	reconnect_timer.timeout.connect(func():
		if has_connected() == false and enablestarthassadapter:
			start_adapter(Store.settings.state.type.to_lower(), Store.settings.state.url, Store.settings.state.token)
	)

## Starts the adapter with the settings from the settings file
## Starts the adapter for the given type and url
func start_adapter(type: String, url: String, token: String):
	print("Starting adapter: %s" % type)
	if api != null:
		api.on_connect.disconnect(_on_connect)
		api.on_disconnect.disconnect(_on_disconnect)
		remove_child(api)
		api.queue_free()
		api = null

	api = apis[type].new(url, token)
	add_child(api)

	api.on_connect.connect(func():
		#Store.house.load_local()
		on_connect.emit()
	)

	api.on_disconnect.connect(func():
		on_disconnect.emit()
	)

func _on_connect():
	on_connect.emit()

func _on_disconnect():
	on_disconnect.emit()

## Returns true if the adapter is connected to the home automation system
func has_connected():
	return api != null and api.hhas_connected()

## Get a list of all devices
func get_devices():
	assert(has_connected(), "Not connected")
	return await api.hget_devices()

## Get a single device by id
func get_device(id: String):
	assert(has_connected(), "Not connected")
	return await api.get_device(id)

## Returns the current state of an entity
func get_state(entity: String):
	if not has_connected():
		return null

	var group = groups.get_group(entity)

	if group != null:
		return await api.get_state(group[0])

	return await api.get_state(entity)

## Updates the state of the entity and returns the resulting state
func set_state(entity: String, state: Variant, attributes: Dictionary={}):
	if not has_connected():
		return null

	var group = groups.get_group(entity)

	if group != null:
		for group_entity in group:
			api.set_state(group_entity, state, attributes)

		return null

	return await api.set_state(entity, state, attributes)

## Watches the state and each time it changes, calls the callback with the changed state, 
# returns a function to stop watching the state
func watch_state(entity: String, callback: Callable):
	# build up the callbacks even if we are not yet connected
	if not has_connected():
		return null

	var group = groups.get_group(entity)
	if group != null:
		api.hwatch_state(group[0], callback)
	return api.hwatch_state(entity, callback)

## Returns true if the adapter has an integration in the home automation system
## allowing to send the room position of the headset.
func has_integration() -> bool:
	return has_connected() and api.has_method("hhas_integration") and api.hhas_integration()

## Updates the room position of the headset in the home automation system
func update_room(room: String) -> void:
	if has_connected() and api.has_method("hupdate_room"):
		pass # not updating room to set the Quest Room
		#api.hupdate_room(room)

## Returns the VoiceHandler if the adapter has a voice assistant
func get_voice_assistant() -> VoiceAssistant:
	assert(has_connected(), "Not connected")

	if api.has_method("get_voice_assistant") == false:
		return null

	return api.get_voice_assistant()

func get_history(entity_id, start, interval, end=null):
	assert(has_connected(), "Not connected")

	if api.has_method("get_history") == false:
		return null

	if groups.is_group(entity_id):
		return null

	return await api.get_history(entity_id, start, interval, end)
