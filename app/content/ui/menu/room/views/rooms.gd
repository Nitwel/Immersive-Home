extends Node3D

const Room = preload ("res://content/system/house/room/room.tscn")
const RoomType = preload ("res://content/system/house/room/room.gd")

const material_selected = preload ("../room_selected.tres")
const material_unselected = preload ("../room_unselected.tres")

@onready var room_button = $Button
@onready var input = $Input
@onready var rooms_map = $Rooms

var selected_room = null:
	set(value):
		if selected_room != null&&value == null:
			room_button.label = "add"
			input.text = "Room %s" % (rooms_map.get_child_count() + 1)

		var old_room = get_room(selected_room)

		if old_room != null:
			old_room.get_node("MeshInstance3D").material_override = material_unselected

		if value != null:
			room_button.label = "edit"
			input.text = value
			edit_room = false
			var new_room = get_room(value)
			if new_room != null:
				new_room.get_node("MeshInstance3D").material_override = material_selected
				
		selected_room = value

var edit_room = false:
	set(value):
		if value == edit_room:
			return

		edit_room = value
		if value:
			room_button.label = "save"
			input.disabled = false
		else:
			room_button.label = "edit"
			input.disabled = true

			if selected_room != null&&selected_room != input.text:
				House.body.rename_room(selected_room, input.text)
				selected_room = input.text

func _ready():
	if Store.house.is_loaded():
		_generate_room_map()
	else:
		Store.house.on_loaded.connect(func():
			_generate_room_map()
		)

	room_button.on_button_down.connect(func():
		if selected_room == null:
			var room_name=input.text
			if get_room(room_name) != null:
				EventSystem.notify("Name already taken", EventNotify.Type.WARNING)
				return
			
			House.body.create_room(room_name, 0)
			House.body.edit_room(room_name)
			selected_room=room_name
			edit_room=true
		else:
			if edit_room:
				edit_room=false

				if !House.body.is_valid_room(selected_room):
					House.body.delete_room(selected_room)
					selected_room=null
				else:
					House.body.edit_room(null)
				_generate_room_map()
			else:
				edit_room=true
				House.body.edit_room(selected_room)
	)

func get_room(room_name):
	if room_name == null:
		return null

	if rooms_map.has_node("%s"% room_name):
		return rooms_map.get_node("%s"% room_name)
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
	var rooms = Store.house.rooms

	var target_size = Vector2(0.3, 0.24)

	for old_room in rooms_map.get_children():
		old_room.queue_free()
		await old_room.tree_exited

	if rooms.size() == 0:
		return

	var current_min = Vector2(rooms[0].corners[0].x, rooms[0].corners[0].y)
	var current_max = current_min

	for room in rooms:
		for corner in room.corners:
			current_min.x = min(current_min.x, corner.x)
			current_min.y = min(current_min.y, corner.y)
			current_max.x = max(current_max.x, corner.x)
			current_max.y = max(current_max.y, corner.y)

	for room in rooms:
		var mesh = RoomType.generate_ceiling_mesh(room)
		
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
	var scale_value = min(target_scale.x, target_scale.y)

	rooms_map.position.x = -current_min.x * scale_value
	rooms_map.position.z = -current_min.y * scale_value

	rooms_map.scale = Vector3(scale_value, scale_value, scale_value)
