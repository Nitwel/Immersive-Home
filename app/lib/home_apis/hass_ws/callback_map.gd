extends Node

## A simple class to manage callbacks for different keys
class_name CallbackMap

## Map of callbacks
var callbacks := {}
var single_callbacks: Array = []

func add(key: Variant, callback: Callable) -> void:
	_validate_key(key)

	if callbacks.has(key):
		callbacks[key].append(callback)
	else:
		callbacks[key] = [callback]

func add_once(key: Variant, callback: Callable) -> void:
	_validate_key(key)

	single_callbacks.append(callback)

	add(key, callback)

func remove(key: Variant, callback: Callable) -> void:
	_validate_key(key)

	if callbacks.has(key):
		callbacks[key].erase(callback)

	if single_callbacks.has(callback):
		single_callbacks.erase(callback)

func call_key(key: Variant, args: Array) -> void:
	_validate_key(key)

	if callbacks.has(key):
		for callback in callbacks[key]:
			callback.callv(args)

			if single_callbacks.has(callback):
				remove(key, callback)

func _validate_key(key: Variant):
	assert(typeof(key) == TYPE_STRING||typeof(key) == TYPE_INT||typeof(key) == TYPE_FLOAT, "key must be a string or number")
