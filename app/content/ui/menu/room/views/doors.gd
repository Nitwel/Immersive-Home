extends Node3D

const ConstructRoomMesh = preload ("res://lib/utils/mesh/construct_room_mesh.gd")

const material_selected = preload ("../room_selected.tres")
const material_unselected = preload ("../room_unselected.tres")

@onready var door_button = $Button
@onready var door_label = $Label3D
@onready var rooms_map = $Rooms
@onready var doors_map = $Doors

var editing_door = R.state(false)

func _ready():
	rooms_map.selectable.value = false

	var button_icon = R.computed(func(_arg):
		if doors_map.selected_door.value == null:
			return "add"
		elif editing_door.value == false:
			return "edit"
		else:
			return "save"
	)

	R.bind(door_button, "label", button_icon)

	var button_label = R.computed(func(_arg):
		if doors_map.selected_door.value == null:
			return "Add Door"
		elif editing_door.value == false:
			return "Edit Door"
		else:
			return "Save Door"
	)

	R.bind(door_label, "text", button_label)

	door_button.on_button_up.connect(func():
		if doors_map.selected_door.value == null:
			var id=House.body.doors.add()
			editing_door.value=true
			doors_map.selected_door.value=id
		elif editing_door.value == false:
			editing_door.value=true
			House.body.doors.edit(doors_map.selected_door.value)
		else:
			House.body.doors.save()
			editing_door.value=false
	)
	