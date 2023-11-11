extends Node3D

const Device = preload("res://content/ui/device/device.tscn")
const Entity = preload("res://content/ui/entity/entity.tscn")
const Switch = preload("res://content/entities/switch/switch.tscn")
const Light = preload("res://content/entities/light/light.tscn")
const Sensor = preload("res://content/entities/sensor/sensor.tscn")

@onready var devices_node: GridContainer3D = $Devices
@onready var next_page_button = $NextPageButton
@onready var previous_page_button = $PreviousPageButton
@onready var page_number_label = $PageNumberLabel
var devices
var page = 0
var last_device_page = 0
var page_size = 20
var pages = 0

var selected_device = null
# Called when the node enters the scene tree for the first time.
func _ready():
	devices = await HomeAdapters.adapter.get_devices()

	next_page_button.get_node("Clickable").on_click.connect(func(_event):
		print("next page")
		next_page()
	)

	previous_page_button.get_node("Clickable").on_click.connect(func(_event):
		previous_page()
	)

	render()

func update_pages():
	if selected_device == null:
		pages = ceil(float(devices.size()) / page_size)
	else:
		for device in devices:
			if device.keys()[0] == selected_device:
				pages = ceil(float(device.values()[0]["entities"].size()) / page_size)

func get_page():
	if selected_device == null:
		return devices.slice(page * page_size, page * page_size + page_size)
	else:
		for device in devices:
			if device.keys()[0] == selected_device:
				return device.values()[0]["entities"].slice(page * page_size, page * page_size + page_size)

func next_page():
	if page >= pages - 1:
		return
	page += 1
	render()

func previous_page():
	if page <= 0:
		return

	page -= 1
	render()

func render():
	update_pages()
	page_number_label.set_text(str(page + 1) + " / " + str(pages))

	previous_page_button.visible = page > 0
	next_page_button.visible = page < pages - 1

	clear_menu()
	if selected_device == null:
		render_devices()
	else:
		render_entities()

func render_devices():
	var page_devices = get_page()

	for device in page_devices:
		var info = device.values()[0]

		var device_instance = Device.instantiate()
		device_instance.id = device.keys()[0]
		device_instance.get_node("Clickable").on_click.connect(func(_event):
			_on_device_click(device_instance.id)
		)
		devices_node.add_child(device_instance)
		device_instance.set_device_name(info["name"])
	
	devices_node._update_container()
		
func render_entities():
	var entities = get_page()

	var back_button = Entity.instantiate()
	back_button.get_node("Clickable").on_click.connect(func(_event):
		_on_entity_click("#back")
	)
	devices_node.add_child(back_button)
	back_button.set_entity_name("#back")
	
	for entity in entities:
		var entity_instance = Entity.instantiate()
		entity_instance.get_node("Clickable").on_click.connect(func(_event):
			_on_entity_click(entity)
		)
		devices_node.add_child(entity_instance)
		entity_instance.set_entity_name(entity)

	devices_node._update_container()
	
func _on_device_click(device_id):
	selected_device = device_id
	last_device_page = page
	page = 0
	
	render()

func _on_entity_click(entity_name):
	if entity_name == "#back":
		selected_device = null
		page = last_device_page
		render()
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
