extends Node3D

const Room = preload ("./room/room.tscn")
const RoomType = preload ("./room/room.gd")
const Miniature = preload ("./mini/miniature.gd")
const Doors = preload ("./doors/doors.gd")
const AlignReference = preload ("./align_reference.gd")

@onready var levels = $Levels
@onready var collision_shape = $Levels/CollisionShape3D
@onready var align_reference: AlignReference = $AlignReference
@onready var mini_view: Miniature = $Levels/Miniature
@onready var doors: Doors = $Levels/Doors

var fixing_reference: bool = false
var editing_room: RoomType = null
var loaded = R.state(false)

func _ready():
	Store.house.on_loaded.connect(func():
		update_house()
	)

func update_house():
	loaded.value = false
	for old_room in get_rooms(0):
		old_room.queue_free()
		await old_room.tree_exited

	align_reference.update_align_reference()

	for index in range(Store.house.state.rooms.size()):
		var new_room = Store.house.state.rooms[index]

		if new_room.corners.size() == 0:
			Store.house.state.rooms.remove_at(index)
			Store.house.save_local()
			continue

		create_room(new_room.name, 0)

	for entity_index in range(Store.house.state.entities.size()):
		var entity = Store.house.state.entities[entity_index]

		var entity_instance = create_entity_in(entity.id, entity.room, entity.get("interface", null))

		if entity_instance == null:
			continue

		entity_instance.global_position = entity.position
		entity_instance.global_rotation = entity.rotation
		entity_instance.scale = Vector3(entity.scale, entity.scale, entity.scale) if entity.has("scale") else Vector3(1, 1, 1)

	loaded.value = true

func create_room(room_name: String, level: int) -> RoomType:
	var existing_room = Store.house.get_room(room_name)

	if existing_room == null:
		Store.house.state.rooms.append({
			"name": room_name,
			"height": 2.0,
			"corners": [],
		})

	var room = Room.instantiate()
	room.name = room_name
	
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

	room.queue_free()
	await room.tree_exited

	var store_room = Store.house.get_room(room_name)

	if store_room != null:
		Store.house.state.rooms.erase(store_room)

	Store.house.save_local()

func is_editiong(room_name):
	return editing_room != null&&editing_room.name == room_name

func find_room(room_name):
	for room in get_rooms(0):
		if room.name == room_name:
			return room
	return null

func find_room_at(entity_position: Vector3):
	for room in get_rooms(0):
		if room.has_point(entity_position):
			return room
	return null

func rename_room(old_room: String, new_name: String):
	var room = find_room(old_room)

	if room == null:
		return

	room.name = new_name

	var store_room = Store.house.get_room(old_room)

	if store_room != null:
		store_room.name = new_name

	save_all_entities()
	Store.house.save_local()

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

func create_entity(entity_id: String, entity_position: Vector3, type=null):
	var room = find_room_at(entity_position)

	if room == null:
		return false

	var entity = EntityFactory.create_entity(entity_id, type)

	if entity == null:
		return null

	room.get_node("Entities").add_child(entity)
	entity.global_position = entity_position

	save_all_entities()

	return entity

func create_entity_in(entity_id: String, room_name: String, type=null):
	var room = find_room(room_name)

	if room == null:
		return false

	var entity = EntityFactory.create_entity(entity_id, type)

	if entity == null:
		return null

	room.get_node("Entities").add_child(entity)
	entity.global_position = room.get_aabb().position + room.get_aabb().size / 2.0

	return entity

func edit_reference():
	fixing_reference = false
	align_reference.visible = true
	align_reference.disabled = false

func fix_reference():
	fixing_reference = true
	align_reference.disabled = false
	align_reference.visible = true
	align_reference.update_initial_positions()

func save_reference():
	if fixing_reference:
		for room in get_rooms(0):
			room.editable = true

		var align_transform = align_reference.global_transform
		transform = align_reference.get_new_transform()
		align_reference.global_transform = align_transform

		align_reference.update_store()

		for room in get_rooms(0):
			room.editable = false

		save_all_entities()

	align_reference.disabled = true
	align_reference.visible = false
	align_reference.update_initial_positions()

	Store.house.save_local()

func save_all_entities():
	Store.house.state.entities.clear()

	for room in get_rooms(0):
		for entity in room.get_node("Entities").get_children():
			var entity_data = {
				"id": entity.entity_id,
				"position": entity.global_position,
				"rotation": entity.global_rotation,
				"scale": entity.scale.x,
				"room": String(room.name),
			}

			if entity.has_method("get_interface"):
				entity_data["interface"] = entity.get_interface()

			Store.house.state.entities.append(entity_data)

	Store.house.state.entities = Store.house.state.entities
	Store.house.save_local()
