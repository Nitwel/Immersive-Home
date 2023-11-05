extends Node

const Hass = preload("res://lib/home_adapters/hass/hass.gd")
const HassWebSocket = preload("res://lib/home_adapters/hass_ws/hass.gd")

enum ADAPTER_TYPES {
	HASS,
	HASS_WS
}

const adapters = {
	ADAPTER_TYPES.HASS: Hass,
	ADAPTER_TYPES.HASS_WS: HassWebSocket
}

const methods = [
	"get_devices",
	"get_device",
	"get_state",
	"set_state",
	"watch_state"
]

var adapter: Node

func _init(type: ADAPTER_TYPES):
	adapter = adapters[type].new()
	add_child(adapter)

	for method in methods:
		assert(adapter.has_method(method), "Adapter does not implement method: " + method)

## Get a list of all devices
func get_devices():
	return await adapter.get_devices()

## Get a single device by id
func get_device(id: String):
	return await adapter.get_device(id)

## Returns the current state of an entity
func get_state(entity: String):
	return await adapter.get_state(entity)

## Updates the state of the entity and returns the resulting state
func set_state(entity: String, state: String, attributes: Dictionary = {}):
	return await adapter.set_state(entity, state, attributes)

## Watches the state and each time it changes, calls the callback with the changed state, returns a function to stop watching the state
func watch_state(entity: String, callback: Callable):
	return adapter.watch_state(entity, callback)
