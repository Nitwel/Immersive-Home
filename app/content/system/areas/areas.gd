extends Node3D

const AreaScene = preload ("./area.tscn")
const AreaNode = preload ("./area.gd")

var editing = false:
	set(value):
		editing = value
		
		if is_node_ready() == false: return

		for area in get_children():
			area.edit = value
			if value == false: area.save_to_store()

		Store.house.save_local()

func _ready():
	Store.house.on_loaded.connect(func():
		load_areas()
	)
	
func load_areas():
	var areas = Store.house.state.areas

	# Remove all areas
	for child in get_children():
		remove_child(child)
		child.queue_free()

	print("Loading areas: ", areas)

	for area in areas:
		var area_scene = AreaScene.instantiate()
		area_scene.id = area.id
		area_scene.edit = editing
		area_scene.display_name = area.name
		add_child(area_scene)
		area_scene.global_position = area.position
		area_scene.global_rotation = area.rotation
		area_scene.size = area.size

		if HomeApi.has_integration() == false:
			continue

		HomeApi.api.integration_handler.create_area.call_deferred(area.id, area.name)

func create_area(name: String):
	var area = AreaScene.instantiate()
	area.id = next_valid_id()
	area.display_name = name
	area.position = App.camera.global_position + App.camera.global_transform.basis.z * - 1
	area.size = Vector3(0.5, 0.5, 0.5)
	area.edit = true
	add_child(area)

	if HomeApi.has_integration() == false:
			return

	HomeApi.api.integration_handler.create_area.call_deferred(area.id, area.name)

func rename_area(id: int, name: String):
	for area in get_children():
		if area is AreaNode&&area.id == id:
			area.display_name = name
			area.save_to_store()
			break

func next_valid_id():
	var id = 0
	for area in Store.house.state.areas:
		if area.id > id:
			id = area.id

	return id + 1
