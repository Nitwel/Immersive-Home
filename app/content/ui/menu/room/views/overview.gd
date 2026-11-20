extends Node3D
## Room setup overview: the floor plan, what's set up so far, and the reference that
## lines the rooms up with the real home.

const Layout = preload ("./setup_layout.gd")
const RoomsMap = preload ("./rooms_map.gd")
const HouseQr = preload ("res://content/system/house/house_qr.gd")

var edit_button: Button3D
var fix_button: Button3D
var qr_link_button: Button3D
var qr_scan_button: Button3D
var qr_linked = R.state(false)

var active = false:
	set(value):
		active = value
		edit_button.label = "save" if value else "edit"
		Layout.set_caption(edit_button, "Save" if value else "Edit")
		Layout.show_action(fix_button, not value)
		_update_qr_buttons()

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
	Layout.hint(self, "Lines the rooms up with your real home. Edit or fix it, or scan a linked QR code.", -0.171)

	edit_button = Layout.action(self, "edit", "Edit", -0.25)
	fix_button = Layout.action(self, "healing", "Fix", -0.25, Layout.COLUMN_X + 0.08)
	qr_link_button = Layout.action(self, "qr_code", "Link", -0.295)
	qr_scan_button = Layout.action(self, "qr_code_scanner", "Scan", -0.295, Layout.COLUMN_X + 0.08)

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

	# Link while the rooms line up, scan when they drifted.
	qr_link_button.on_button_down.connect(App.house.qr.link)
	qr_scan_button.on_button_down.connect(App.house.qr.align)

	App.house.qr.on_busy_changed.connect(func(_busy):
		qr_link_button.active=App.house.qr.mode == HouseQr.Mode.LINK
		qr_scan_button.active=App.house.qr.mode == HouseQr.Mode.ALIGN
	)

	R.effect(func(_arg):
		qr_linked.value=str(Store.house.state.qr_text) != ""
		_update_qr_buttons()
	)

func _update_qr_buttons():
	if qr_link_button == null:
		return

	Layout.show_action(qr_link_button, not active)
	Layout.show_action(qr_scan_button, not active&&qr_linked.value)
