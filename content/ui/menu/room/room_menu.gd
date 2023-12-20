extends Node3D

const Room = preload("res://content/system/house/room/room.tscn")
const RoomType = preload("res://content/system/house/room/room.gd")

const window_scene = preload("./window.tscn")

@onready var background = $Background
@onready var add_room_button = $Interface/AddRoom
@onready var save_room_button = $Interface/SaveRoom
@onready var input = $Interface/Input
@onready var rooms_map = $Interface/Rooms

var selected_room = null:
	set(value):
		selected_room = value
		if value != null:
			save_room_button.visible = true
		else:
			save_room_button.visible = false

var edit_room = false:
	set(value):
		edit_room = value
		if value:
			save_room_button.label = "save"
		else:
			save_room_button.label = "edit"

func _ready():
	background.visible = false

	HomeApi.on_connect.connect(func():
		var rooms = House.body.get_rooms(0)

		# for room in rooms:
		# 	var mesh = room.wall_mesh

	)

	add_room_button.on_button_down.connect(func():
		var room_name = input.text
		House.body.create_room(room_name, 0)
		selected_room = room_name
		edit_room = true
		add_room_button.visible = false
	)

	save_room_button.on_button_down.connect(func():
		if edit_room:
			edit_room = false
			add_room_button.visible = true
			House.body.edit_room(null)
			_generate_room_map()
		else:
			edit_room = true
			House.body.edit_room(selected_room)
	)

func _on_click(event: EventPointer):
	if event.target.get_parent() == rooms_map:
		var room_name = event.target.name
		selected_room = room_name
		edit_room = false
		add_room_button.visible = false
		House.body.edit_room(selected_room)

func _generate_room_map():
	var rooms = House.body.get_rooms(0)

	var target_size = Vector2(0.3, 0.2)

	for old_room in rooms_map.get_children():
		old_room.queue_free()

	var current_min = Vector2(0, 0)
	var current_max = Vector2(0, 0)

	for room in rooms:
		var body = StaticBody3D.new()

		var mesh = room.ceiling_mesh.mesh
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = mesh
		mesh_instance.material_override = load("res://content/system/house/room/walls.tres")
		body.add_child(mesh_instance)

		var collision_shape = CollisionShape3D.new()
		collision_shape.shape = mesh.create_trimesh_shape()
		body.add_child(collision_shape)

		rooms_map.add_child(body)

		if mesh.get_aabb().position.x < current_min.x:
			current_min.x = mesh.get_aabb().position.x

		if mesh.get_aabb().position.z < current_min.y:
			current_min.y = mesh.get_aabb().position.z

		if mesh.get_aabb().end.x > current_max.x:
			current_max.x = mesh.get_aabb().end.x

		if mesh.get_aabb().end.z > current_max.y:
			current_max.y = mesh.get_aabb().end.z

	var current_size = current_max - current_min

	var target_scale = target_size / current_size
	var scale_value = max(target_scale.x, target_scale.y)

	rooms_map.scale = Vector3(scale_value, scale_value, scale_value)
