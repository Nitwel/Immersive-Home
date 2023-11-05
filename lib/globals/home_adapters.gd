extends Node

var Adapter = preload("res://lib/home_adapters/adapter.gd")

var adapter = Adapter.new(Adapter.ADAPTER_TYPES.HASS)
var adapter_ws = Adapter.new(Adapter.ADAPTER_TYPES.HASS_WS)

func _ready():
	add_child(adapter)
	add_child(adapter_ws)
	
