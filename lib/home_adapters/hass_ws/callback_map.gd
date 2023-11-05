extends Node

class_name CallbackMap

var callbacks := {}

func add(key: Variant, callback: Callable) -> void:
	_validate_key(key)

	if callbacks.has(key):
		callbacks[key].append(callback)
	else:
		callbacks[key] = [callback]

func add_once(key: Variant, callback: Callable) -> void:
	_validate_key(key)

	var fn: Callable
	
	fn = func(args: Array):
		remove(key, fn)
		callback.callv(args)

	add(key, fn)

func remove(key: Variant, callback: Callable) -> void:
	_validate_key(key)

	if callbacks.has(key):
		callbacks[key].erase(callback)

func call_key(key: Variant, args: Array) -> void:
	_validate_key(key)

	if callbacks.has(key):
		for callback in callbacks[key]:
			callback.callv(args)

func _validate_key(key: Variant):
	assert(typeof(key) == TYPE_STRING || typeof(key) == TYPE_INT || typeof(key) == TYPE_FLOAT, "key must be a string or number")
