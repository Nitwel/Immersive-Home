extends Node3D
## Room setup: add, edit, rename and delete rooms, picked on the floor plan.

const Layout = preload ("./setup_layout.gd")
const RoomsMap = preload ("./rooms_map.gd")
const UI = preload ("res://content/entities/entity_ui.gd")

var rooms_map: RoomsMap
var editing_room = R.state(false)

func _ready():
	rooms_map = Layout.plan(self, RoomsMap.Mode.ROOMS)

	var title = Layout.title(self, "New room")
	var hint = Layout.hint(self, "")
	var input = UI.input(self, Vector3(Layout.COLUMN_X + Layout.COLUMN_WIDTH / 2.0, -0.165, 0), Layout.COLUMN_WIDTH)
	var room_button = Layout.action(self, "add", "Add room", -0.21)
	var delete_button = Layout.action(self, "delete", "Delete", -0.25)
	var sync_room_button = Layout.action(self, "sync", "Sync from Quest", -0.29)

	R.effect(func(_arg):
		var selected = rooms_map.selected_room.value
		if selected == null:
			Layout.set_title(title, "New room")
			hint.text = "Tap a room to select it, or name a new one and add it."
		else:
			Layout.set_title(title, str(selected), RoomsMap.room_color(str(selected)))
			hint.text = "Move its corners in your room, then save." if editing_room.value else "Edit to move its corners or rename it."
	)

	R.effect(func(_arg):
		if rooms_map.selected_room.value == null:
			room_button.label = "add"
			Layout.set_caption(room_button, "Add room")
		elif editing_room.value:
			room_button.label = "save"
			Layout.set_caption(room_button, "Save")
		else:
			room_button.label = "edit"
			Layout.set_caption(room_button, "Edit")
	)

	R.effect(func(_arg):
		input.disabled = editing_room.value == false and rooms_map.selected_room.value != null
	)

	R.effect(func(_arg):
		if rooms_map.selected_room.value == null:
			# Rebuilds when the rooms change, so a free name is picked again.
			Store.house.state.rooms
			var i = 1
			while _has_room("Room %s" % i):
				i += 1
			input.text = "Room %s" % i
		else:
			input.text = rooms_map.selected_room.value
	)

	R.effect(func(_arg):
		Layout.show_action(sync_room_button, editing_room.value and App.main.meta_scene_manager != null)
		Layout.show_action(delete_button, rooms_map.selected_room.value != null)
	)

	if !Store.house.is_loaded(): await Store.house.on_loaded

	if App.main.meta_scene_manager != null:
		sync_room_button.on_button_up.connect(func():
			App.main.meta_scene_manager.create_scene_anchors()

			await get_tree().create_timer(1.0).timeout

			var data = MetaTools.spatial_entites.get_corners_and_height()

			App.house.editing_room.state_machine.current_state.create_from_corners(data.corners, data.height)
		)

	delete_button.on_button_up.connect(func():
		var selected_room = rooms_map.selected_room

		if selected_room.value != null:
			App.house.delete_room(selected_room.value)
			selected_room.value = null
			editing_room.value = false
			rooms_map.selectable.value = true
	)

	room_button.on_button_down.connect(func():
		var selected_room = rooms_map.selected_room

		if selected_room.value == null:
			var room_name = input.text
			if _has_room(room_name):
				EventSystem.notify("Name already taken", EventNotify.Type.WARNING)
				return

			App.house.create_room(room_name)
			App.house.edit_room(room_name)
			selected_room.value = room_name
			editing_room.value = true
			rooms_map.selectable.value = false
		else:
			editing_room.value = !editing_room.value
			rooms_map.selectable.value = !editing_room.value

			if editing_room.value == false:
				if !App.house.is_valid_room(selected_room.value):
					EventSystem.notify("Room was deleted as it had less than 3 corners.", EventNotify.Type.WARNING)
					App.house.delete_room(selected_room.value)
					selected_room.value = null
					return

				if selected_room.value != null && selected_room.value != input.text:
					App.house.rename_room(selected_room.value, input.text)
					selected_room.value = input.text

				App.house.edit_room(null)
			else:
				App.house.edit_room(selected_room.value)
	)

## Whether a room of [param room_name] exists (also one too small to draw).
func _has_room(room_name: String) -> bool:
	for room in Store.house.state.rooms:
		if str(room.name) == room_name:
			return true
	return false
