extends Node

const Hass = preload("res://lib/home_apis/hass/hass.gd")
const HassWebSocket = preload("res://lib/home_apis/hass_ws/hass.gd")


const apis = {
	"hass": Hass,
	"hass_ws": HassWebSocket
}

const methods = [
	"get_devices",
	"get_device",
	"get_state",
	"set_state",
	"watch_state"
]

signal on_connect()
signal on_disconnect()
var api: Node

func _ready():
	print("HomeApi ready")

	var config = ConfigData.load_config()

	if config.has("api_type") && config.has("url") && config.has("token"):
		var type = config["api_type"]
		var url = config["url"] + "/api/websocket"
		var token = config["token"]

		start_adapter(type, url, token)
	

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
		SaveSystem.load()
		on_connect.emit()
	)

	api.on_disconnect.connect(func():
		on_disconnect.emit()
	)

	for method in methods:
		assert(api.has_method(method), "%s Api does not implement method: %s" % [type, method])

func _on_connect():
	on_connect.emit()

func _on_disconnect():
	on_disconnect.emit()

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
	return await api.get_state(entity)

## Updates the state of the entity and returns the resulting state
func set_state(entity: String, state: String, attributes: Dictionary = {}):
	assert(has_connected(), "Not connected")
	return await api.set_state(entity, state, attributes)

## Watches the state and each time it changes, calls the callback with the changed state, returns a function to stop watching the state
func watch_state(entity: String, callback: Callable):
	assert(has_connected(), "Not connected")
	return api.watch_state(entity, callback)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST || what == NOTIFICATION_WM_GO_BACK_REQUEST:
		# SaveSystem.save()
		pass