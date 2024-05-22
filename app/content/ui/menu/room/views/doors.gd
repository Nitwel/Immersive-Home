extends Node3D

const ConstructRoomMesh = preload ("res://lib/utils/mesh/construct_room_mesh.gd")

const material_selected = preload ("../room_selected.tres")
const material_unselected = preload ("../room_unselected.tres")

@onready var door_button = $Button
@onready var delete_button = $DeleteButton
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

	R.effect(func(_arg):
		delete_button.disabled=doors_map.selected_door.value == null
		delete_button.visible=doors_map.selected_door.value != null
	)

	door_button.on_button_up.connect(func():
		if doors_map.selected_door.value == null:
			var id=App.house.doors.add()
			editing_door.value=true
			doors_map.selected_door.value=id
		elif editing_door.value == false:
			editing_door.value=true
			App.house.doors.edit(doors_map.selected_door.value)
		else:
			App.house.doors.save()
			editing_door.value=false
	)

	delete_button.on_button_up.connect(func():
		if doors_map.selected_door.value != null:
			App.house.doors.delete(doors_map.selected_door.value)
			doors_map.selected_door.value=null
	)
	