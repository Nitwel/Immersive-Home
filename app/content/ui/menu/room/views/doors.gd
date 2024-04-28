extends Node3D

const ConstructRoomMesh = preload ("res://lib/utils/mesh/construct_room_mesh.gd")

const material_selected = preload ("../room_selected.tres")
const material_unselected = preload ("../room_unselected.tres")

@onready var door_button = $Button
@onready var door_label = $Label3D
@onready var rooms_map = $Rooms
@onready var doors_map = $Doors

var selected_door = R.state(null)
var editing_door = R.state(false)

func _ready():
	# Generate Room Mesh
	R.effect(func(_arg):
		pass
	)

	door_button.on_button_up.connect(func():
		House.body.doors.edit(1)
	)
	