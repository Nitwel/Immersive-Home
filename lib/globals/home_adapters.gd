extends Node

const Adapter = preload("res://lib/home_adapters/adapter.gd")

var adapter = Adapter.new(Adapter.ADAPTER_TYPES.HASS_WS)
# var adapter_http = Adapter.new(Adapter.ADAPTER_TYPES.HASS)

func _ready():
	add_child(adapter)
	# add_child(adapter_http)
	
