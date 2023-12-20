extends Node3D

const Room = preload("./room/room.tscn")
const RoomType = preload("./room/room.gd")

@onready var levels = $Levels

var editing_room: RoomType = null

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

	
