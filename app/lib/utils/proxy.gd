extends RefCounted
class_name Proxy

signal on_set(new_value: Variant)

var gettable: Callable
var settable: Callable

func _init(gettable: Callable, settable: Callable):
	self.gettable = gettable
	self.settable = settable

	

var value: Variant:
	get:
		return gettable.call()
	set(new_value):
		settable.call(new_value)
		on_set.emit(new_value)
		
