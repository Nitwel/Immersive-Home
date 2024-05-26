extends Node3D

const WallCornerScene = preload ("../room/wall_corner.tscn")
const WallEdgeScene = preload ("../room/wall_edge.tscn")

## int | null
var editing_door = null

var room1 = null
var room2 = null
var room1_corner1 = null
var room1_corner2 = null
var room2_corner1 = null
var room2_corner2 = null

@onready var ray_cast = $RayCast3D

func _ready():
	pass

func is_editing():
	return editing_door != null

func is_valid():
	return room1 != null&&room2 != null&&room1_corner1 != null&&room1_corner2 != null&&room2_corner1 != null&&room2_corner2 != null

func add():
	var doors = Store.house.state.doors

	var next_index = 0
	for i in range(doors.size()):
		next_index = max(next_index, doors[i].id)
	edit(next_index + 1)

	return next_index + 1

func delete(door):
	Store.house.state.doors = Store.house.state.doors.filter(func(d): return d.id != door)
	Store.house.save_local()

	App.controller_left.show_grid = false
	App.controller_right.show_grid = false

func edit(door):
	var doors = Store.house.state.doors
	editing_door = door

	var existing_door = null

	for i in range(doors.size()):
		if doors[i].id == door:
			existing_door = doors[i]
			break

	App.controller_left.show_grid = true
	App.controller_right.show_grid = true

	if existing_door != null:
		room1 = App.house.find_room(existing_door.room1)
		room2 = App.house.find_room(existing_door.room2)

		room1_corner1 = WallCornerScene.instantiate()
		room1_corner1.global_position = existing_door.room1_position1
		room1_corner1.get_node("Clickable").on_grab_move.connect(_move_corner.bind(room1, room1_corner1))
		add_child(room1_corner1)

		room1_corner2 = WallCornerScene.instantiate()
		room1_corner2.global_position = existing_door.room1_position2
		room1_corner2.get_node("Clickable").on_grab_move.connect(_move_corner.bind(room1, room1_corner2))
		add_child(room1_corner2)

		room2_corner1 = WallCornerScene.instantiate()
		room2_corner1.global_position = existing_door.room2_position1
		room2_corner1.get_node("Clickable").on_grab_move.connect(_move_corner.bind(room2, room2_corner1))
		add_child(room2_corner1)

		room2_corner2 = WallCornerScene.instantiate()
		room2_corner2.global_position = existing_door.room2_position2
		room2_corner2.get_node("Clickable").on_grab_move.connect(_move_corner.bind(room2, room2_corner2))
		add_child(room2_corner2)

		for room in App.house.get_rooms():
			if room != room1&&room != room2:
				room.get_node("WallCollision/Clickable").on_click.connect(_add_corner.bind(room))
			else:
				room.get_node("WallCollision/Clickable").on_click.disconnect(_add_corner.bind(room))

	for room in App.house.get_rooms():
		if door != null:
			room.get_node("WallCollision/Clickable").on_click.connect(_add_corner.bind(room))
		else:
			room.get_node("WallCollision/Clickable").on_click.disconnect(_add_corner.bind(room))

func discard():
	_clear()

func save():
	var doors = Store.house.state.doors

	if is_valid() == false:
		EventSystem.notify("Door is not valid", EventNotify.Type.WARNING)
		return

	var existing_door_index = -1
	for i in range(doors.size()):

		if doors[i].id == editing_door:
			existing_door_index = i
			break

	var door = {
		"id": editing_door,
		"room1": room1.name,
		"room2": room2.name,
		"room1_position1": room1_corner1.global_position,
		"room1_position2": room1_corner2.global_position,
		"room2_position1": room2_corner1.global_position,
		"room2_position2": room2_corner2.global_position
	}

	if existing_door_index == - 1:
		doors.append(door)
	else:
		doors[existing_door_index] = door

	Store.house.state.doors = Store.house.state.doors

	room1.update()
	room2.update()

	Store.house.save_local()
	
	_clear()

func _clear():
	editing_door = null
	room1 = null
	room2 = null

	App.controller_left.show_grid = true
	App.controller_right.show_grid = true

	if room1_corner1 != null:
		remove_child(room1_corner1)
		room1_corner1.queue_free()
		room1_corner1 = null

	if room1_corner2 != null:
		remove_child(room1_corner2)
		room1_corner2.queue_free()
		room1_corner2 = null

	if room2_corner1 != null:
		remove_child(room2_corner1)
		room2_corner1.queue_free()
		room2_corner1 = null

	if room2_corner2 != null:
		remove_child(room2_corner2)
		room2_corner2.queue_free()
		room2_corner2 = null

func _add_corner(event: EventPointer, room):
	_match_connected_room(event.ray.get_collision_point(), event.ray.get_collision_normal() * - 1)

	if room1_corner1 == null:
		if ray_cast.get_collider() == null:
			EventSystem.notify("Could not find connected room", EventNotify.Type.WARNING)
			return

		var connected_room = ray_cast.get_collider().get_parent()

		room1 = room
		room2 = connected_room

		room1_corner1 = WallCornerScene.instantiate()
		room1_corner1.global_position = event.ray.get_collision_point()
		room1_corner1.get_node("Clickable").on_grab_move.connect(_move_corner.bind(room, room1_corner1))
		add_child(room1_corner1)

		room2_corner1 = WallCornerScene.instantiate()
		room2_corner1.global_position = ray_cast.get_collision_point()
		room2_corner1.get_node("Clickable").on_grab_move.connect(_move_corner.bind(connected_room, room2_corner1))
		add_child(room2_corner1)
		
	elif room1_corner2 == null:
		if ray_cast.get_collider() == null:
			EventSystem.notify("Could not find connected room", EventNotify.Type.WARNING)
			return

		if room1 != room:
			EventSystem.notify("2nd corner must be in the same room", EventNotify.Type.WARNING)
			return

		var connected_room = ray_cast.get_collider().get_parent()

		if room2 != connected_room:
			EventSystem.notify("Connected rooms do not match", EventNotify.Type.WARNING)
			return

		room1_corner2 = WallCornerScene.instantiate()
		room1_corner2.global_position = event.ray.get_collision_point()
		room1_corner2.get_node("Clickable").on_grab_move.connect(_move_corner.bind(room, room1_corner2))
		add_child(room1_corner2)

		room2_corner2 = WallCornerScene.instantiate()
		room2_corner2.global_position = ray_cast.get_collision_point()
		room2_corner2.get_node("Clickable").on_grab_move.connect(_move_corner.bind(connected_room, room2_corner2))
		add_child(room2_corner2)

func _move_corner(event: EventPointer, room, corner):
	_match_room(event.ray.global_position, event.ray.to_global(event.ray.target_position) - event.ray.global_position)

	if ray_cast.get_collider() == null||ray_cast.get_collider().get_parent() != room:
		return

	var collision_point = ray_cast.get_collision_point()
	
	_match_connected_room(collision_point, ray_cast.get_collision_normal() * - 1)

	var connected_collision_point = ray_cast.get_collision_point()
	
	if ray_cast.get_collider() == null||ray_cast.get_collider().get_parent() != _get_connected_room(room):
		return

	corner.global_position = collision_point
	_get_connected_corner(corner).global_position = connected_collision_point

func _get_connected_room(room):
	return room1 if room == room2 else room2

func _get_connected_corner(corner):
	match corner:
		room1_corner1:
			return room2_corner1
		room1_corner2:
			return room2_corner2
		room2_corner1:
			return room1_corner1
		room2_corner2:
			return room1_corner2

func _match_room(pos: Vector3, dir: Vector3):
	ray_cast.global_position = pos
	ray_cast.target_position = dir.normalized() * 1000
	ray_cast.force_raycast_update()

func _match_connected_room(pos: Vector3, dir: Vector3):
	ray_cast.global_position = pos
	ray_cast.target_position = dir.normalized() * 1000
	ray_cast.force_raycast_update()