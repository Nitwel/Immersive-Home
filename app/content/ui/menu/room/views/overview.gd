extends Node3D
## Room setup overview: the floor plan, what's set up so far, and the reference that
## lines the rooms up with the real home.

const Layout = preload ("./setup_layout.gd")
const RoomsMap = preload ("./rooms_map.gd")

var edit_button: Button3D
var fix_button: Button3D

var active = false:
	set(value):
		active = value
		edit_button.label = "save" if value else "edit"
		Layout.set_caption(edit_button, "Save" if value else "Edit")
		Layout.show_action(fix_button, not value)

func _ready():
	Layout.plan(self, RoomsMap.Mode.VIEW)

	var title = Layout.title(self, "Your home")
	var stats = Layout.hint(self, "")
	R.effect(func(_arg):
		var rooms = Store.house.state.rooms.size()
		var doors = Store.house.state.doors.size()
		stats.text = "%s %s · %s %s" % [rooms, "room" if rooms == 1 else "rooms", doors, "door" if doors == 1 else "doors"]
	)

	Layout.title(self, "Reference").position.y = -0.155
	Layout.hint(self, "Lines the rooms up with your real home. Edit it, or fix it if they drifted.", -0.171)

	edit_button = Layout.action(self, "edit", "Edit", -0.25)
	fix_button = Layout.action(self, "healing", "Fix", -0.25, Layout.COLUMN_X + 0.08)

	edit_button.on_button_down.connect(func():
		if active:
			App.house.save_reference()
		else:
			App.house.edit_reference()
		active = !active
	)

	fix_button.on_button_down.connect(func():
		App.house.fix_reference()
		active = true
	)
