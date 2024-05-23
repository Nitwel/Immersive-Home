extends Node3D

const Room = preload ("res://content/system/house/room/room.tscn")
const RoomsMap = preload ("rooms_map.gd")

@onready var room_button = $Button
@onready var input = $Input
@onready var rooms_map: RoomsMap = $Rooms
@onready var sync_room_button: Button3D = $SyncRoomsButton
@onready var delete_button: Button3D = $DeleteButton
@onready var sync_room_label: Label3D = $SyncRoomsLabel

var editing_room = R.state(false)

func _ready():

	R.effect(func(_arg):
		if rooms_map.selected_room.value == null:
			room_button.label="add"
		elif editing_room.value:
			room_button.label="save"
		else:
			room_button.label="edit"
	)

	R.effect(func(_arg):
		input.disabled=editing_room.value == false
	)

	R.effect(func(_arg):
		if rooms_map.selected_room.value == null:
			var i=1
			while rooms_map.get_room("Room %s" % i) != null:
				i += 1

			input.text="Room %s" % i
		else:
			input.text=rooms_map.selected_room.value
	)

	R.effect(func(_arg):
		sync_room_button.visible=editing_room.value
		sync_room_label.visible=editing_room.value
		sync_room_button.disabled=!editing_room.value
		delete_button.visible=editing_room.value
		delete_button.disabled=!editing_room.value
	)

	if !Store.house.is_loaded(): await Store.house.on_loaded

	if App.main.meta_scene_manager == null:
		remove_child(sync_room_button)
		remove_child(sync_room_label)
	else:
		sync_room_button.on_button_up.connect(func():
			App.main.meta_scene_manager.create_scene_anchors()

			await get_tree().create_timer(1.0).timeout

			var data=MetaTools.spatial_entites.get_corners_and_height()

			App.house.editing_room.state_machine.current_state.create_from_corners(data.corners, data.height)
		)

	delete_button.on_button_up.connect(func():
		var selected_room=rooms_map.selected_room

		if selected_room.value != null:
			App.house.delete_room(selected_room.value)
			selected_room.value=null
			editing_room.value=false
			rooms_map.selectable.value=true
	)

	room_button.on_button_down.connect(func():
		var selected_room=rooms_map.selected_room

		if selected_room.value == null:
			var room_name=input.text
			if rooms_map.get_room(room_name) != null:
				EventSystem.notify("Name already taken", EventNotify.Type.WARNING)
				return
			
			App.house.create_room(room_name)
			App.house.edit_room(room_name)
			selected_room.value=room_name
			editing_room.value=true
			rooms_map.selectable.value=false
		else:
			editing_room.value=!editing_room.value
			rooms_map.selectable.value=!editing_room.value

			if editing_room.value == false:
				if !App.house.is_valid_room(selected_room.value):
					EventSystem.notify("Room was deleted as it had less than 3 corners.", EventNotify.Type.WARNING)
					App.house.delete_room(selected_room.value)
					selected_room.value=null
					return

				if selected_room.value != null&&selected_room.value != input.text:
					App.house.rename_room(selected_room.value, input.text)
					selected_room.value=input.text
				
				App.house.edit_room(null)
			else:
				App.house.edit_room(selected_room.value)
	)
