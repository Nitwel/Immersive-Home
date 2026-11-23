extends RefCounted
## The ready-made apartment of the demo mode, with the demo devices already placed.
##
## Laid out in a frame where the user stands at the origin, in the middle of the
## living room, looking towards -Z. build() turns it into a house store state
## around the given spot, so the rooms are built around wherever demo mode starts.
##
##            -Z
##   +------------+ +--------+
##   |  Bedroom   | |Bathroom|
##   +---door-----+ +--door--+
##   +-------------------------+ +---------+
##   |                         | | Kitchen |
##   |   Living Room   (you)  door         |
##   |                         | +---------+
##   +-------------------------+
##            +Z

const HEIGHT = 2.6
const DOOR_HEIGHT = 2.05

## Room name -> [min corner, max corner] on the floor (x, z), meters. The rooms are
## 10 cm apart, like the walls of a scanned home.
const ROOMS = {
	"Living Room": [Vector2(-2.6, -2.2), Vector2(2.4, 2.3)],
	"Kitchen": [Vector2(2.5, -2.2), Vector2(5.5, 0.8)],
	"Bedroom": [Vector2(-2.6, -6.3), Vector2(0.9, -2.3)],
	"Bathroom": [Vector2(1.0, -4.8), Vector2(3.5, -2.3)],
}

## [room 1, room 2, door start, door end]: a door in the wall between two rooms,
## from start to end on room 1's side. Room 2's side is the matching spot on its wall.
const DOORS = [
	["Living Room", "Kitchen", Vector2(2.4, -1.4), Vector2(2.4, -0.5)],
	["Living Room", "Bedroom", Vector2(-1.6, -2.2), Vector2(-0.7, -2.2)],
	["Living Room", "Bathroom", Vector2(1.4, -2.2), Vector2(2.2, -2.2)],
]

## [entity id, room, position (x, height, z)]. Widgets on a wall sit a little in
## front of it and face into their room.
const ENTITIES = [
	["light.living_room_ceiling", "Living Room", Vector3(0.0, 2.3, 0.2)],
	["light.living_room_floor_lamp", "Living Room", Vector3(-2.2, 1.6, 1.9)],
	["media_player.living_room_speaker", "Living Room", Vector3(-1.6, 1.4, 2.2)],
	["climate.living_room_thermostat", "Living Room", Vector3(-2.5, 1.45, -0.4)],
	["sensor.living_room_temperature", "Living Room", Vector3(-2.5, 1.45, 0.4)],
	["sensor.living_room_humidity", "Living Room", Vector3(-2.5, 1.3, 0.4)],
	["cover.living_room_blinds", "Living Room", Vector3(0.9, 1.4, 2.2)],
	["binary_sensor.balcony_door", "Living Room", Vector3(1.8, 1.4, 2.2)],
	["person.sam", "Living Room", Vector3(-0.3, 1.45, -2.1)],
	["weather.home", "Living Room", Vector3(0.6, 1.45, -2.1)],
	["lock.front_door", "Living Room", Vector3(2.3, 1.3, 1.6)],
	["light.kitchen_spots", "Kitchen", Vector3(4.0, 2.3, -0.7)],
	["switch.coffee_machine", "Kitchen", Vector3(5.4, 1.2, -1.0)],
	["timer.oven", "Kitchen", Vector3(5.4, 1.45, -0.2)],
	["sensor.kitchen_temperature", "Kitchen", Vector3(4.0, 1.45, -2.1)],
	["sensor.kitchen_humidity", "Kitchen", Vector3(4.0, 1.3, -2.1)],
	["sensor.dishwasher_status", "Kitchen", Vector3(3.2, 1.0, 0.7)],
	["binary_sensor.kitchen_window", "Kitchen", Vector3(4.6, 1.5, 0.7)],
	["todo.shopping_list", "Kitchen", Vector3(3.1, 1.45, -2.1)],
	["light.bedside_lamp", "Bedroom", Vector3(-2.2, 0.8, -5.9)],
	["cover.bedroom_curtains", "Bedroom", Vector3(-0.9, 1.4, -6.2)],
	["sensor.bedroom_temperature", "Bedroom", Vector3(0.8, 1.45, -4.6)],
	["sensor.bedroom_humidity", "Bedroom", Vector3(0.8, 1.3, -4.6)],
	["humidifier.bedroom_humidifier", "Bedroom", Vector3(-2.5, 1.0, -3.4)],
	["calendar.family", "Bedroom", Vector3(-2.5, 1.45, -4.6)],
	["time.wake_up_alarm", "Bedroom", Vector3(-1.4, 1.2, -6.2)],
	["light.bathroom_mirror", "Bathroom", Vector3(2.2, 1.9, -4.7)],
	["fan.bathroom_fan", "Bathroom", Vector3(3.4, 1.9, -3.6)],
	["sensor.bathroom_temperature", "Bathroom", Vector3(1.1, 1.45, -3.6)],
	["sensor.bathroom_humidity", "Bathroom", Vector3(1.1, 1.3, -3.6)],
	["water_heater.boiler", "Bathroom", Vector3(3.4, 1.4, -2.8)],
]

## A house store state (see lib/stores/house.gd) with the apartment built around
## [param origin]: its position on the floor and its turn around the up axis.
static func build(origin: Transform3D) -> Dictionary:
	var frame = _flatten(origin)

	var rooms = []
	for room_name in ROOMS:
		var bounds = ROOMS[room_name]
		var corners = [bounds[0], Vector2(bounds[1].x, bounds[0].y), bounds[1], Vector2(bounds[0].x, bounds[1].y)]
		rooms.append({
			"name": room_name,
			"corners": corners.map(func(corner): return _floor(frame, corner)),
			"height": HEIGHT,
		})

	var doors = []
	for i in DOORS.size():
		var door = DOORS[i]
		var start: Vector2 = door[2]
		var end: Vector2 = door[3]
		var across = _wall_normal(door[0], start, end) * 0.1
		doors.append({
			"id": i,
			"room1": door[0],
			"room2": door[1],
			"room1_position1": frame * Vector3(start.x, DOOR_HEIGHT, start.y),
			"room1_position2": frame * Vector3(end.x, DOOR_HEIGHT, end.y),
			"room2_position1": frame * Vector3(start.x + across.x, DOOR_HEIGHT, start.y + across.y),
			"room2_position2": frame * Vector3(end.x + across.x, DOOR_HEIGHT, end.y + across.y),
		})

	var entities = []
	for entity in ENTITIES:
		var local: Vector3 = entity[2]
		var center = _center(entity[1])
		var facing = Vector3(center.x - local.x, 0, center.y - local.z)
		# Widgets show their front towards +Z, turn that into the room.
		var yaw = atan2(facing.x, facing.z) if facing.length() > 0.3 else 0.0
		entities.append({
			"id": entity[0],
			"position": frame * local,
			"rotation": Vector3(0, frame.basis.get_euler().y + yaw, 0),
			"scale": 1.0,
			"room": entity[1],
		})

	var living_room = ROOMS["Living Room"]

	return {
		"rooms": rooms,
		"doors": doors,
		"entities": entities,
		"align_position1": frame * Vector3(living_room[0].x, 0, living_room[1].y),
		"align_position2": frame * Vector3(living_room[1].x, 0, living_room[1].y),
		"anchor_uuid": "",
		"anchor_position": Vector3(),
		"anchor_yaw": 0.0,
		"qr_text": "",
		"qr_transform": Transform3D(),
		"map_heading": 0.0,
	}

## Only the floor position and the turn around the up axis of [param origin].
static func _flatten(origin: Transform3D) -> Transform3D:
	var forward = -origin.basis.z
	forward.y = 0
	var yaw = atan2(-forward.x, -forward.z) if forward.length() > 0.01 else 0.0
	return Transform3D(Basis(Vector3.UP, yaw), Vector3(origin.origin.x, 0, origin.origin.z))

static func _floor(frame: Transform3D, corner: Vector2) -> Vector2:
	var point = frame * Vector3(corner.x, 0, corner.y)
	return Vector2(point.x, point.z)

static func _center(room_name: String) -> Vector2:
	return (ROOMS[room_name][0] + ROOMS[room_name][1]) / 2.0

## Unit vector from the wall a door is in, out of [param room_name] (towards the
## room on the other side).
static func _wall_normal(room_name: String, start: Vector2, end: Vector2) -> Vector2:
	var along = (end - start).normalized()
	var normal = Vector2(along.y, -along.x)
	var middle = (start + end) / 2.0
	return normal if (middle + normal - _center(room_name)).length() > (middle - _center(room_name)).length() else -normal
