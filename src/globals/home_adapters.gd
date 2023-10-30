extends Node

var Adapter = preload("res://src/home_adapters/adapter.gd")

var adapter = Adapter.new(Adapter.ADAPTER_TYPES.HASS)
    