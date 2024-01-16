extends Node3D

const Room = preload("res://content/system/house/room/room.tscn")
const RoomType = preload("res://content/system/house/room/room.gd")

const material_selected = preload("./room_selected.tres")
const material_unselected = preload("./room_unselected.tres")

const window_scene = preload("./window.tscn")

@onready var background = $Background
@onready var room_button = $Interface/Button
@onready var input = $Interface/Input
@onready var rooms_map = $Interface/Rooms

var selected_room = null:
	set(value):
		if selected_room != null && value == null:
			room_button.label = "add"
			input.text = "New Room %s" % (rooms_map.get_child_count() + 1)

		if selected_room != null:
			var old_room = get_room(selected_room)
			if old_room != null:
				old_room.get_node("MeshInstance3D").material_override = material_unselected

		if value != null:
			input.text = value
			edit_room = false
			var new_room = get_room(value)
			if new_room != null:
				new_room.get_node("MeshInstance3D").material_override = material_selected

				
		selected_room = value

var edit_room = false:
	set(value):
		edit_room = value
		if value:
			room_button.label = "save"
		else:
			room_button.label = "edit"

func _ready():
	background.visible = false

	HomeApi.on_connect.connect(func():
		# var rooms = House.body.get_rooms(0)

		# for room in rooms:
		# 	var mesh = room.wall_mesh
		pass
	)

	room_button.on_button_down.connect(func():
		if selected_room == null:
			var room_name = input.text
			if get_room(room_name) != null:
				EventSystem.notify("Name already taken", EventNotify.Type.WARNING)
				return
			
			House.body.create_room(room_name, 0)
			selected_room = room_name
			edit_room = true
		else:
			if edit_room:
				edit_room = false

				if !House.body.is_valid_room(selected_room):
					House.body.delete_room(selected_room)
					selected_room = null
				else:
					House.body.edit_room(null)
				_generate_room_map()
			else:
				edit_room = true
				House.body.edit_room(selected_room)
	)

func get_room(room_name):
	if rooms_map.has_node("%s" % room_name):
		return rooms_map.get_node("%s" % room_name)
	return null

func _on_click(event: EventPointer):
	if event.target.get_parent() == rooms_map:
		var room_name = event.target.name

		if selected_room == room_name:
			selected_room = null
			House.body.edit_room(null)
			return

		selected_room = room_name

func _generate_room_map():
	var rooms = House.body.get_rooms(0)

	var target_size = Vector3(0.3, 1, 0.24)

	for old_room in rooms_map.get_children():
		old_room.queue_free()
		await old_room.tree_exited

	var aabb = House.body.get_level_aabb(0)
	var current_min = aabb.position
	var current_max = aabb.position + aabb.size

	for room in rooms:
		var mesh = room.ceiling_mesh.mesh
		if mesh == null:
			continue

		var body = StaticBody3D.new()
		body.name = room.name

		
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.name = "MeshInstance3D"
		mesh_instance.mesh = mesh
		mesh_instance.material_override = material_unselected if selected_room != room.name else material_selected
		body.add_child(mesh_instance)

		var collision_shape = CollisionShape3D.new()
		collision_shape.shape = mesh.create_trimesh_shape()
		body.add_child(collision_shape)

		rooms_map.add_child(body)

	if current_min == null:
		return

	var current_size = current_max - current_min
	var target_scale = target_size / current_size
	var scale_value = min(target_scale.x, target_scale.z)

	rooms_map.position.x = -current_min.x * scale_value
	rooms_map.position.z = -current_min.z * scale_value

	rooms_map.scale = Vector3(scale_value, scale_value, scale_value)
