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

## Removes every callback bound to [param target], e.g. lambdas created inside a node
## that is about to be freed. Call it before the target is gone.
func remove_owner(target: Object) -> void:
	for key in callbacks.keys():
		callbacks[key] = callbacks[key].filter(func(callback: Callable): return callback.get_object() != target)

	single_callbacks = single_callbacks.filter(func(callback: Callable): return callback.get_object() != target)

func call_key(key: Variant, args: Array) -> void:
	_validate_key(key)

	if callbacks.has(key):
		# Iterate a copy, callbacks may add or remove callbacks while running
		for callback in callbacks[key].duplicate():
			callback.callv(args)

			if single_callbacks.has(callback):
				remove(key, callback)

func _validate_key(key: Variant):
	assert(typeof(key) == TYPE_STRING||typeof(key) == TYPE_INT||typeof(key) == TYPE_FLOAT, "key must be a string or number")
