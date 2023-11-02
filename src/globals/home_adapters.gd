extends Node

var Adapter = preload("res://src/home_adapters/adapter.gd")

var adapter = Adapter.new(Adapter.ADAPTER_TYPES.HASS)
var adapter_ws = Adapter.new(Adapter.ADAPTER_TYPES.HASS_WS)

func _ready():
	add_child(adapter_ws)

	var timer = Timer.new()
	timer.set_wait_time(1)
	timer.set_one_shot(true)
	
	print("timer started")
	timer.timeout.connect(func():
		print("timer done")

		var result = await adapter_ws.get_state("light.living_room")
		print(result)
	)

	add_child(timer)
	timer.start()

	
