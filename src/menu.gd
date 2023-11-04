extends Node3D

const Device = preload("res://scenes/device.tscn")
const Entity = preload("res://scenes/entity.tscn")
const Switch = preload("res://scenes/entities/switch.tscn")
const Light = preload("res://scenes/entities/light.tscn")
const Sensor = preload("res://scenes/entities/sensor.tscn")

@onready var devices_node = $Devices
var devices

var selected_device = null
# Called when the node enters the scene tree for the first time.
func _ready():
	devices = await HomeAdapters.adapter.load_devices()
	render_devices()

func render_devices():
	var x = 0
	var y = 0
	
	for device in devices:
		var info = device.values()[0]

		var device_instance = Device.instantiate()
		device_instance.set_position(Vector3(y * 0.08, 0, -x * 0.08))
		device_instance.click.connect(_on_device_click)
		device_instance.id = device.keys()[0]

		devices_node.add_child(device_instance)

		device_instance.set_device_name(info["name"])

		x += 1
		if x % 5 == 0:
			x = 0
			y += 1
		
func render_entities():
	var x = 0
	var y = 0
	
	var info

	for device in devices:
		if device.keys()[0] == selected_device:
			info = device.values()[0]
			break
	
	if info == null:
		return

	var entities = info["entities"]
	
	for entity in entities:
		var entity_instance = Entity.instantiate()
		entity_instance.set_position(Vector3(y * 0.08, 0, -x * 0.08))
		entity_instance.click.connect(_on_entity_click)

		devices_node.add_child(entity_instance)
		
		entity_instance.set_entity_name(entity)
		
		x += 1
		if x % 5 == 0:
			x = 0
			y += 1
	
func _on_device_click(device_id):
	selected_device = device_id
	print(selected_device)
	clear_menu()
	render_entities()

func _on_entity_click(entity_name):
	print(entity_name)
	selected_device = null
	clear_menu()
	render_devices()

	var type = entity_name.split(".")[0]
	print(type)

	if type == "switch":
		var switch = Switch.instantiate()
		switch.entity_id = entity_name

		switch.set_position(global_position)
		get_node("/root").add_child(switch)

	if type == "light":
		var light = Light.instantiate()
		light.entity_id = entity_name

		light.set_position(global_position)
		get_node("/root").add_child(light)

	if type == "sensor":
		var sensor = Sensor.instantiate()
		sensor.entity_id = entity_name

		sensor.set_position(global_position)
		get_node("/root").add_child(sensor)
	
func clear_menu():
	for child in devices_node.get_children():
		devices_node.remove_child(child)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
