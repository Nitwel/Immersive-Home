extends Node

const hass = preload("res://src/home_adapters/hass/hass.gd")

enum ADAPTER_TYPES {
	HASS
}

const adapters = {
	ADAPTER_TYPES.HASS: hass
}

const methods = [
	"load_devices",
	"get_state",
	"set_state"
]

var adapter: Node

func _init(type: ADAPTER_TYPES):
	adapter = adapters[type].new()

	for method in methods:
		assert(adapter.has_method(method), "Adapter does not implement method: " + method)
		
func load_devices():
	return await adapter.load_devices()

func get_state(entity: String):
	return await adapter.get_state(entity)

func set_state(entity: String, state: String, attributes: Dictionary = {}):
	return await adapter.set_state(entity, state, attributes)