extends Node3D

const RoomMaterial = preload ("res://content/system/house/room/room_next.tres")

const Room = preload ("./room/room.tscn")
const RoomType = preload ("./room/room.gd")
const Doors = preload ("./doors/doors.gd")
const AlignReference = preload ("./align_reference.gd")

@onready var rooms = $Rooms
@onready var align_reference: AlignReference = $AlignReference
@onready var doors: Doors = $Doors

var editing_room: RoomType = null
var loaded = R.state(false)

func _ready():
	Store.house.on_loaded.connect(func():
		update_house()
	)
	if Store.house.state.rooms.size() != 0:
		print("emitting update_house after signal connected")
		Store.house.on_loaded.emit()

func update_house():
	print("*** Creating entities from Store.house.state.rooms to $Rooms")
	loaded.value = false
	for old_room in get_rooms():
		old_room.get_parent().remove_child(old_room)
		old_room.queue_free()

	print("disabled update_align_reference")
	# align_reference.update_align_reference()
	for index in range(Store.house.state.rooms.size()):
		var new_room = Store.house.state.rooms[index]
		if new_room.corners.size() == 0:
			Store.house.state.rooms.remove_at(index)
			continue
		create_room(new_room.name)
	for entity_index in range(Store.house.state.entities.size()):
		var entity = Store.house.state.entities[entity_index]
		var entity_instance = create_entity_in(entity.id, entity.room, entity.get("interface", null))
		if entity_instance == null:
			continue
		entity_instance.global_position = entity.position
		entity_instance.global_rotation = entity.rotation
		entity_instance.scale = Vector3(entity.scale, entity.scale, entity.scale) if entity.has("scale") else Vector3(1, 1, 1)
		if entity.has("options") and entity_instance.has_method("set_options"):
			entity_instance.set_options(entity.options)
	loaded.value = true

func create_room(room_name: String) -> RoomType:
	var existing_room = Store.house.get_room(room_name)

	if existing_room == null:
		Store.house.state.rooms.append({
			"name": room_name,
			"height": 2.0,
			"corners": [],
		})

	var room = Room.instantiate()
	room.name = room_name
	
	rooms.add_child(room)

	return room

func edit_room(room_name):
	var room = find_room(room_name)

	if room == editing_room:
		return

	App.controller_left.show_grid = false
	App.controller_right.show_grid = false

	if editing_room != null:
		editing_room.editable = false
		editing_room = null
	
	if room != null:
		room.editable = true
		editing_room = room
		App.controller_left.show_grid = true
		App.controller_right.show_grid = true

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

	rooms.remove_child(room)
	room.queue_free()

	Store.house.state.rooms = Store.house.state.rooms.filter(func(r): return r.name != room_name)
	Store.house.save_local()

func is_editiong(room_name):
	return editing_room != null&&editing_room.name == room_name

func find_room(room_name):
	for room in get_rooms():
		if room.name == room_name:
			return room
	return null

func find_room_at(entity_position: Vector3):
	for room in get_rooms():
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

func get_rooms_aabb():
	var rooms = get_rooms()
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

func get_rooms():
	return rooms.get_children()

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

func allstationsoptions():
	var res = [ ]
	for room in get_rooms():
		for entity in room.get_node("Entities").get_children():
			if entity and entity.has_method("get_options"):
				var options = entity.get_options()
				if options.has("station_id"):
					res.append(options)
	return res
	
func find_station_byname(ns):
	for room in get_rooms():
		for entity in room.get_node("Entities").get_children():
			if entity.entity_id.split(".")[0] == "text":
				if entity.station_name == ns:
					return entity
	return null

func find_station_byid(stationid):
	for room in get_rooms():
		for entity in room.get_node("Entities").get_children():
			if entity and entity.has_method("get_options"):
				var options = entity.get_options()
				if options.has("station_id") and options["station_id"] == stationid:
					return entity
	return null

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


func blueborder_alignment(bshow):
	align_reference.disabled = not bshow
	align_reference.visible = bshow
	$AlignRefShadow.visible = bshow
	if bshow:
		align_reference.update_initial_positions()
		$AlignRefShadow.global_transform = 	align_reference.get_marker_transform()
	RoomMaterial.set_shader_parameter("show_border", bshow)
	
func move_alignment():
	align_reference.update_stored_align_reference()
	align_reference.update_initial_positions()
	$AlignRefShadow.global_transform = 	align_reference.get_marker_transform()
	Store.house.save_local()

func bring_alignment_close():
	align_reference.bring_alignment_close()

func apply_alignment():
	var align_transform = align_reference.global_transform
	var applytransform = align_reference.get_marker_transform()*$AlignRefShadow.global_transform.inverse()
	applytransform.origin.y = 0
	for door in Store.house.state.doors:
		door.room1_position1 = applytransform*door.room1_position1
		door.room1_position2 = applytransform*door.room1_position2
		door.room2_position1 = applytransform*door.room2_position1
		door.room2_position2 = applytransform*door.room2_position2
	for room in Store.house.state.rooms:
		var acorners = [ ]
		for corner in room.corners:
			var p = Vector3(corner.x, room.height, corner.y)
			var ap = applytransform*p
			acorners.append(Vector2(ap.x, ap.z))
		room.corners = acorners

	transform = applytransform
	save_all_entities() # reads them all through the set transform
	transform = Transform3D()
	move_alignment()

	# force update
	Store.house.state.rooms = Store.house.state.rooms
	App.house.update_house()

func save_all_entities():
	print("*** Copying entities from $Rooms to Store.house.state")
	Store.house.state.entities.clear()
	for room in get_rooms():
		for entity in room.get_node("Entities").get_children():
			var entity_data = {
				"id": entity.entity_id,
				"position": entity.global_position,
				"rotation": entity.global_rotation,
				"scale": entity.scale.x,
				"room": String(room.name),
				"_node_iid":entity.get_instance_id()
			}

			if entity.has_method("get_interface"):
				entity_data["interface"] = entity.get_interface()

			if entity.has_method("get_options"):
				entity_data["options"] = entity.get_options()

			Store.house.state.entities.append(entity_data)

	# this is the refresh
	Store.house.state.entities = Store.house.state.entities
	Store.house.save_local()
