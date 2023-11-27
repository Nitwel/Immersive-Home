extends RefCounted

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