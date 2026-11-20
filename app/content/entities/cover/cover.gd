extends Entity
## cover: blinds, curtains, garage doors... Open/stop/close buttons, the state and,
## when the cover supports it, a position slider (0 = closed, 100 = open).

const Entity = preload ("../entity.gd")
const UI = preload ("../entity_ui.gd")

const WIDTH = 0.24
const HEIGHT = 0.17
## Height without the position slider row.
const HEIGHT_COMPACT = 0.135
const TOP = HEIGHT / 2

## CoverEntityFeature flags
const FEATURE_OPEN = 1
const FEATURE_CLOSE = 2
const FEATURE_SET_POSITION = 4
const FEATURE_STOP = 8

## device_class -> [icon when open, icon when closed]
const ICONS = {
	"curtain": ["curtains", "curtains_closed"],
	"shade": ["roller_shades", "roller_shades_closed"],
	"garage": ["garage_door", "garage"],
	"gate": ["door_sliding", "door_sliding"],
	"door": ["door_front", "door_front"],
	"window": ["window", "window"],
}
const DEFAULT_ICONS = ["blinds", "blinds_closed"]

const STATE_NAMES = {"open": "Open", "closed": "Closed", "opening": "Opening…", "closing": "Closing…"}

var panel: Panel3D
var type_icon: Label3D
var name_label: Label3D
var state_label: Label3D
var open_button: Button3D
var stop_button: Button3D
var close_button: Button3D
var position_slider: Slider3D

var state := "unknown"
## current_position, or null for covers that only know open/closed.
var cover_position = null

func _ready():
	super()
	icon.value = DEFAULT_ICONS[0]

	panel = UI.card(self, Vector2(WIDTH, HEIGHT))
	type_icon = UI.label(self, DEFAULT_ICONS[0], 22, Vector3(-WIDTH / 2 + 0.02, TOP - 0.02, 0), HORIZONTAL_ALIGNMENT_CENTER, true)
	name_label = UI.label(self, entity_id, 22, Vector3(-WIDTH / 2 + 0.034, TOP - 0.02, 0))
	state_label = UI.label(self, "", 30, Vector3(0, TOP - 0.058, 0), HORIZONTAL_ALIGNMENT_CENTER)
	open_button = UI.icon_button(self, "keyboard_arrow_up", Vector3(-0.055, TOP - 0.103, 0), 0.04)
	stop_button = UI.icon_button(self, "stop", Vector3(0, TOP - 0.103, 0), 0.04)
	close_button = UI.icon_button(self, "keyboard_arrow_down", Vector3(0.055, TOP - 0.103, 0), 0.04)
	position_slider = UI.slider(self, Vector3(0, TOP - 0.148, 0), WIDTH - 0.03)

	open_button.on_button_up.connect(func(): _send("open"))
	stop_button.on_button_up.connect(func(): _send("stop"))
	close_button.on_button_up.connect(func(): _send("close"))
	position_slider.on_value_changed.connect(func(value):
		HomeApi.set_state(entity_id, "position", {"position": int(value)})
	)

	set_state(await HomeApi.get_state(entity_id))

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

func set_state(state_info):
	if state_info == null:
		return

	state = str(state_info["state"])
	var attributes = UI.attributes_of(state_info)
	var available = not UI.is_unavailable(state)

	UI.fit_label(name_label, UI.entity_name(entity_id, attributes), WIDTH - 0.046)

	cover_position = attributes.get("current_position")
	if cover_position != null:
		cover_position = clampi(int(cover_position), 0, 100)

	var fallback = FEATURE_OPEN | FEATURE_CLOSE | FEATURE_STOP | (FEATURE_SET_POSITION if cover_position != null else 0)
	var features = UI.features_of(attributes, fallback)

	var icons = ICONS.get(str(attributes.get("device_class", "")), DEFAULT_ICONS)
	icon.value = icons[1] if state == "closed" else icons[0]
	type_icon.text = icon.value

	var text = STATE_NAMES.get(state, state.capitalize())
	# 0/100 % repeats "Closed"/"Open", so only show positions in between.
	if available and cover_position != null and cover_position > 0 and cover_position < 100:
		text += " · %d %%" % cover_position
	state_label.text = text

	var fully_open = cover_position == 100 if cover_position != null else state == "open"
	var fully_closed = cover_position == 0 if cover_position != null else state == "closed"
	_set_button(open_button, features & FEATURE_OPEN, available and state != "opening" and not fully_open)
	_set_button(close_button, features & FEATURE_CLOSE, available and state != "closing" and not fully_closed)
	_set_button(stop_button, features & FEATURE_STOP, available)

	var has_slider = (features & FEATURE_SET_POSITION) != 0
	UI.set_shown(position_slider, has_slider)
	if has_slider and cover_position != null:
		position_slider.value = cover_position

	if has_slider:
		UI.resize_card(self, panel, Vector2(WIDTH, HEIGHT))
	else:
		UI.resize_card(self, panel, Vector2(WIDTH, HEIGHT_COMPACT), TOP - HEIGHT_COMPACT / 2)

func _set_button(button: Button3D, supported: int, enabled: bool):
	UI.set_shown(button, supported != 0)
	button.disabled = not enabled
	UI.dim_button(button, not enabled)

func _send(action: String):
	if UI.is_unavailable(state):
		return
	HomeApi.set_state(entity_id, action)

func quick_action():
	if state == "opening" or state == "closing":
		_send("stop")
	elif state == "closed":
		_send("open")
	else:
		_send("close")
