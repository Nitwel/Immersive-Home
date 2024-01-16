extends Node3D

const Room = preload("./room/room.tscn")
const RoomType = preload("./room/room.gd")

@onready var levels = $Levels
@onready var collision_shape = $Levels/CollisionShape3D

var editing_room: RoomType = null
var mini_view: bool = false:
	set(value):
		mini_view = value
		update_mini_view()

func create_room(room_name: String, level: int) -> RoomType:
	if editing_room != null:
		editing_room.editable = false
		editing_room = null

	var room = Room.instantiate()
	room.name = room_name
	room.editable = true
	editing_room = room
	
	get_level(level).add_child(room)

	return room

func edit_room(room_name):
	var room = find_room(room_name)

	if room == editing_room:
		return

	if editing_room != null:
		editing_room.editable = false
		editing_room = null
	
	if room != null:
		room.editable = true
		editing_room = room

func is_valid_room(room_name):
	var room = find_room(room_name)

	if room == null:
		return

	return room.wall_corners.get_child_count() >= 3
			

func delete_room(room_name):
	var room = find_room(room_name)

	if room == null:
		return

	if editing_room == room:
		editing_room = null

	room.get_parent().remove_child(room)
	room.queue_free()

func is_editiong(room_name):
	return editing_room != null && editing_room.name == room_name

func find_room(room_name):
	for level in levels.get_children():
		for room in level.get_children():
			if room.name == room_name:
				return room
	return null

func find_room_at(entity_position: Vector3):
	for level in levels.get_children():
		for room in level.get_children():
			if room.has_point(entity_position):
				return room
	return null

func get_level(level: int):
	return levels.get_child(level)

func get_level_aabb(level: int):
	var rooms = get_level(level).get_children()
	if rooms.size() == 0:
		return AABB()

	var min_pos = rooms[0].get_aabb().position
	var max_pos = min_pos + rooms[0].get_aabb().size

	for room in rooms:
		var room_min = room.get_aabb().position
		var room_max = room_min + room.get_aabb().size

		min_pos.x = min(min_pos.x, room_min.x)
		min_pos.y = min(min_pos.y, room_min.y)
		min_pos.z = min(min_pos.z, room_min.z)

		max_pos.x = max(max_pos.x, room_max.x)
		max_pos.y = max(max_pos.y, room_max.y)
		max_pos.z = max(max_pos.z, room_max.z)

	return AABB(min_pos, max_pos - min_pos)

func get_rooms(level: int):
	return get_level(level).get_children()

func create_entity(entity_id: String, entity_position: Vector3):
	var room = find_room_at(entity_position)

	if room == null:
		return

	var entity = EntityFactory.create_entity(entity_id)

	if entity == null:
		return

	room.add_child(entity)
	entity.global_position = entity_position

func update_mini_view():
	collision_shape.disabled = !mini_view

	if mini_view:
		var aabb = get_level_aabb(0)
		aabb.position.y = -0.03
		aabb.size.y = 0.06
		var center = aabb.position + aabb.size / 2.0

		collision_shape.global_position = center
		collision_shape.shape.size = aabb.size
	else:
		levels.position = Vector3(0, 0, 0)

	levels.scale.x = 0.2 if mini_view else 1.0
	levels.scale.y = 0.2 if mini_view else 1.0
	levels.scale.z = 0.2 if mini_view else 1.0

	for room in get_rooms(0):
		room.state_machine.change_to("Mini" if mini_view else "View")