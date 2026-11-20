extends Object
## Builds the floor plan that is synced to the home automation system, so other
## apps can draw the rooms and the entities inside them in 2D or 3D.
##
## The house store keeps everything in the headset's tracking space, which moves
## whenever tracking is recentered and the user fixes the align reference. The
## floor plan is instead expressed in the house frame, which the align reference
## defines and which therefore stays the same across sessions:
##   origin: the first align corner, on the floor (y = 0)
##   +X:     towards the second align corner
##   +Y:     up
##   +Z:     X cross Y (Godot's right-handed, Y-up convention)
## A 2D view uses the [x, z] floor coordinates. Units are meters, angles radians.
##
## Format (version 1):
##   version: int
##   units: "m"
##   heading: float, compass bearing in degrees (clockwise from north) the -Z axis points to
##   rooms: [{name, height, polygon: [[x, z], ...]}]
##   doors: [{id, rooms: [room1, room2], room1: [[x, y, z], [x, y, z]], room2: [[x, y, z], [x, y, z]]}]
##   entities: [{id, room, interface, position: [x, y, z], rotation: [x, y, z], scale}]
##     rotation is an Euler rotation in YXZ order, so rotation[1] is the yaw.

const VERSION = 1

## Coordinates are rounded to millimeters, finer is noise from the hand tracking.
const PRECISION = 0.001

## The house frame in tracking space: transforms house coordinates to tracking space.
static func get_house_frame(state) -> Transform3D:
	var p1: Vector3 = state.align_position1
	var p2: Vector3 = state.align_position2

	var x_axis := Vector3(p2.x - p1.x, 0, p2.z - p1.z)

	# The align reference was never placed, see align_reference.gd
	if x_axis.length_squared() < 0.000001:
		x_axis = Vector3.RIGHT

	x_axis = x_axis.normalized()

	var basis := Basis(x_axis, Vector3.UP, x_axis.cross(Vector3.UP))

	# Rooms stand on y = 0 in tracking space, keep the floor there.
	return Transform3D(basis, Vector3(p1.x, 0, p1.z))

## Builds the floor plan from the state of the house store.
static func build(state) -> Dictionary:
	var frame := get_house_frame(state)
	var to_house := frame.affine_inverse()

	var rooms = []
	for room in state.rooms:
		if room.corners.size() < 3:
			continue

		var polygon = []
		for corner in room.corners:
			var point: Vector3 = to_house * Vector3(corner.x, 0, corner.y)
			polygon.append([_round(point.x), _round(point.z)])

		rooms.append({
			"name": str(room.name),
			"height": _round(float(room.height)),
			"polygon": polygon,
		})

	var doors = []
	for door in state.doors:
		doors.append({
			"id": door.id,
			"rooms": [str(door.room1), str(door.room2)],
			"room1": [_point(to_house * door.room1_position1), _point(to_house * door.room1_position2)],
			"room2": [_point(to_house * door.room2_position1), _point(to_house * door.room2_position2)],
		})

	var entities = []
	for entity in state.entities:
		var rotation: Vector3 = (to_house.basis * Basis.from_euler(entity.rotation)).get_euler()

		entities.append({
			"id": str(entity.id),
			"room": str(entity.room),
			"interface": entity.get("interface"),
			"position": _point(to_house * entity.position),
			"rotation": _point(rotation),
			"scale": _round(float(entity.get("scale", 1.0))),
		})

	return {
		"version": VERSION,
		"units": "m",
		"heading": _round(_get_heading(state, frame)),
		"rooms": rooms,
		"doors": doors,
		"entities": entities,
	}

## The house store's map_heading is the bearing of tracking space's -Z axis,
## turn it into the bearing of the house frame's -Z axis.
static func _get_heading(state, frame: Transform3D) -> float:
	var forward := -frame.basis.z
	# Positive angles around +Y turn counter-clockwise seen from above, bearings clockwise.
	var turn := rad_to_deg(Vector3.FORWARD.signed_angle_to(forward, Vector3.UP))

	return fposmod(float(state.map_heading) - turn, 360.0)

static func _point(value: Vector3) -> Array:
	return [_round(value.x), _round(value.y), _round(value.z)]

static func _round(value: float) -> float:
	return snappedf(value, PRECISION)
