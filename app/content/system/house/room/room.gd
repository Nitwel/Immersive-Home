extends Node3D

const ConstructRoomMesh = preload ("res://lib/utils/mesh/construct_room_mesh.gd")
const ConstructDoorMesh = preload ("res://lib/utils/mesh/construct_door_mesh.gd")
const RoomMaterial = preload ("res://content/system/house/room/states/room.tres")

@onready var wall_corners = $Ceiling/WallCorners
@onready var wall_edges = $Ceiling/WallEdges
@onready var wall_mesh: MeshInstance3D = $WallMesh
@onready var ceiling_mesh: MeshInstance3D = $CeilingMesh
@onready var wall_collision = $WallCollision/CollisionShape3D

@onready var room_floor = $Floor
@onready var room_ceiling = $Ceiling
@onready var doors = $Doors

@onready var state_machine: StateMachine = $StateMachine

var editable: bool = false:
	set(value):
		editable = value
		
		if !is_inside_tree(): return
		
		update()

var _show_border: bool = false

func _ready():
	Update.props(self, ["editable"])

func has_point(point: Vector3) -> bool:
	return get_aabb().has_point(point)

func update():
	if editable:
		state_machine.change_to("Edit")
	else:
		state_machine.change_to("View")

func get_aabb():
	var room_store = Store.house.get_room(name)

	if room_store == null:
		return AABB()

	var corners = room_store.corners

	if corners.size() == 0:
		return AABB()

	var min_pos = Vector3(corners[0].x, 0, corners[0].y)
	var max_pos = min_pos

	for corner in corners:
		min_pos.x = min(min_pos.x, corner.x)
		min_pos.z = min(min_pos.z, corner.y)

		max_pos.x = max(max_pos.x, corner.x)
		max_pos.z = max(max_pos.z, corner.y)

	min_pos.y = 0
	max_pos.y = room_store.height

	return AABB(to_global(min_pos), to_global(max_pos) - to_global(min_pos))

func generate_wall_mesh():
	var room = Store.house.get_room(name)

	if room == null||room.corners.size() < 3:
		return null

	var corners = room.corners
	var height = room.height
	var doors = []

	for door in Store.house.state.doors:
		if door.room1 == name:
			doors.append([door.room1_position1, door.room1_position2])
		elif door.room2 == name:
			doors.append([door.room2_position1, door.room2_position2])

	# return ConstructRoomMesh.generate_wall_mesh(corners, height)
	return ConstructRoomMesh.generate_wall_mesh_with_doors(corners, height, doors)

static func generate_ceiling_mesh(room: Dictionary):
	var corners = room.corners

	return ConstructRoomMesh.generate_ceiling_mesh(corners)

func generate_doors_mesh():
	for door in Store.house.state.doors:
		if door.room1 != name:
			continue

		var door_mesh = MeshInstance3D.new()

		doors.add_child(door_mesh)

		if Geometry2D.is_polygon_clockwise([
			Vector2(door.room1_position1.x, door.room1_position1.z),
			Vector2(door.room2_position1.x, door.room2_position1.z),
			Vector2(door.room2_position2.x, door.room2_position2.z),
			Vector2(door.room1_position2.x, door.room1_position2.z)
		]):
			door_mesh.mesh = ConstructDoorMesh.generate_door_mesh(door.room1_position2, door.room2_position2, door.room2_position1, door.room1_position1)
		else:
			door_mesh.mesh = ConstructDoorMesh.generate_door_mesh(door.room1_position1, door.room2_position1, door.room2_position2, door.room1_position2)

		door_mesh.material_override = RoomMaterial

func clear_doors_mesh():
	for door in doors.get_children():
		doors.remove_child(door)
		door.queue_free()