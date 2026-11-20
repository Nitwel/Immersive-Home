extends Node3D
## Room setup: add, edit and delete the doors between rooms, picked on the floor plan.

const Layout = preload ("./setup_layout.gd")
const RoomsMap = preload ("./rooms_map.gd")

var doors_map: RoomsMap
var editing_door = R.state(false)

func _ready():
	doors_map = Layout.plan(self, RoomsMap.Mode.DOORS)

	var title = Layout.title(self, "Doors")
	var hint = Layout.hint(self, "")
	var door_button = Layout.action(self, "add", "Add door", -0.21)
	var delete_button = Layout.action(self, "delete", "Delete", -0.25)

	R.effect(func(_arg):
		var count = Store.house.state.doors.size()
		if doors_map.selected_door.value == null:
			Layout.set_title(title, "Doors (%s)" % count if count > 0 else "Doors")
			hint.text = "Tap a door to select it, or add one between two rooms."
		else:
			Layout.set_title(title, "Door", RoomsMap.ACCENT)
			hint.text = "Move its corners in your room, then save." if editing_door.value else "Edit to move its corners."
	)

	R.effect(func(_arg):
		if doors_map.selected_door.value == null:
			door_button.label = "add"
			Layout.set_caption(door_button, "Add door")
		elif editing_door.value == false:
			door_button.label = "edit"
			Layout.set_caption(door_button, "Edit")
		else:
			door_button.label = "save"
			Layout.set_caption(door_button, "Save")
	)

	R.effect(func(_arg):
		Layout.show_action(delete_button, doors_map.selected_door.value != null)
	)

	door_button.on_button_up.connect(func():
		if doors_map.selected_door.value == null:
			var id = App.house.doors.add()
			editing_door.value = true
			doors_map.selected_door.value = id
		elif editing_door.value == false:
			editing_door.value = true
			App.house.doors.edit(doors_map.selected_door.value)
		else:
			App.house.doors.save()
			editing_door.value = false
	)

	delete_button.on_button_up.connect(func():
		if doors_map.selected_door.value != null:
			App.house.doors.delete(doors_map.selected_door.value)
			doors_map.selected_door.value = null
	)
