extends Node3D

const Device = preload("res://content/ui/device/device.tscn")
const Entity = preload("res://content/ui/entity/entity.tscn")
const Switch = preload("res://content/entities/switch/switch.tscn")
const Light = preload("res://content/entities/light/light.tscn")
const Sensor = preload("res://content/entities/sensor/sensor.tscn")

@onready var devices_node: GridContainer3D = $Devices
var devices

var selected_device = null
# Called when the node enters the scene tree for the first time.
func _ready():
	devices = await HomeAdapters.adapter.get_devices()
	render_devices()

func render_devices():
	for device in devices:
		var info = device.values()[0]

		var device_instance = Device.instantiate()
		device_instance.click.connect(_on_device_click)
		device_instance.id = device.keys()[0]
		devices_node.add_child(device_instance)
		device_instance.set_device_name(info["name"])
	
	devices_node._update_container()
		
func render_entities():
	var info

	for device in devices:
		if device.keys()[0] == selected_device:
			info = device.values()[0]
			break
	
	if info == null:
		return

	var entities = info["entities"]

	var back_button = Entity.instantiate()
	back_button.click.connect(_on_entity_click)
	devices_node.add_child(back_button)
	back_button.set_entity_name("#back")
	
	for entity in entities:
		var entity_instance = Entity.instantiate()
		entity_instance.click.connect(_on_entity_click)
		devices_node.add_child(entity_instance)
		entity_instance.set_entity_name(entity)

	devices_node._update_container()
	
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

	if entity_name == "#back":
		return

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
