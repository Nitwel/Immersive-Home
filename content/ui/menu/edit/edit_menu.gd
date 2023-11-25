extends Node3D

const Device = preload("./device/device.tscn")
const Entity = preload("./entity/entity.tscn")
const EntityCreator = preload("./entity_creator.gd")

@onready var devices_node: GridContainer3D = $Devices
@onready var next_page_button = $Buttons/NextPageButton
@onready var previous_page_button = $Buttons/PreviousPageButton
@onready var page_number_label = $PageNumberLabel
var devices = []
var page = 0
var last_device_page = 0
var page_size = 20
var pages = 0

var selected_device = null
# Called when the node enters the scene tree for the first time.
func _ready():
	next_page_button.get_node("Clickable").on_click.connect(func(_event):
		print("next page")
		next_page()
	)

	previous_page_button.get_node("Clickable").on_click.connect(func(_event):
		previous_page()
	)

func _enter_tree():
	if HomeApi.has_connected():
		load_devices()
	else:
		HomeApi.on_connect.connect(func():
			if is_inside_tree():
				load_devices()
		)

func load_devices():
	if devices.size() == 0:
		devices = await HomeApi.get_devices()
		render()

		HomeApi.on_disconnect.connect(func():
			devices = []
			if is_inside_tree():
				render()
		)

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
	if devices.size() == 0:
		return

	update_pages()
	page_number_label.set_text(str(page + 1) + " / " + str(pages))

	var has_prev_page = page > 0
	var has_next_page = page < pages - 1

	previous_page_button.visible = has_prev_page
	previous_page_button.disabled = !has_prev_page
	next_page_button.visible = has_next_page
	next_page_button.disabled = !has_next_page

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
		device_instance.set_device_name.call_deferred(info["name"])
	
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
		AudioPlayer.play_effect("click")
		render()
		return

	var type = entity_name.split(".")[0]
	AudioPlayer.play_effect("spawn")

	var entity = EntityCreator.create_entity(type, entity_name)
	entity.set_position(global_position)
	get_node("/root").add_child(entity)
	
func clear_menu():
	for child in devices_node.get_children():
		devices_node.remove_child(child)
		child.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
