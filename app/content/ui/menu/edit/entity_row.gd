@tool
extends Container3D
## One entity in the edit menu: icon, name, live state and a Place action.
## Unsupported entities are dimmed and can't be placed.

signal on_place()

const DeviceUtils = preload ("./device_utils.gd")
const ButtonScene = preload ("res://content/ui/components/button/button.tscn")

const NAME_SIZE = 10
const STATE_SIZE = 8
const ACTION_WIDTH = 0.046
const PLACED_COLOR = Color(0.56, 0.88, 0.68)

var entity_id: String
var display_name: String
## Extra text after the state, e.g. the device name in search results
var context: String
var supported: bool

var placed := false:
	set(value):
		placed = value
		if is_node_ready():
			_update_action()

var icon_button: Button3D
var _place_button: Button3D
var _status: Label3D
var _state_label: Label3D
var _unwatch = null

func _init(id: String, name_text: String, context_text: String, row_size: Vector3):
	entity_id = id
	display_name = name_text
	context = context_text
	supported = EntityFactory.is_supported(id)
	size = row_size

func _ready():
	var front = size.z + 0.001
	var left = -size.x / 2
	var alpha = 1.0 if supported else 0.4

	icon_button = ButtonScene.instantiate()
	icon_button.size = Vector3(size.y, size.y, size.z)
	icon_button.icon = true
	icon_button.label = EntityFactory.get_entity_icon(DeviceUtils.domain_of(entity_id)) if supported else "block"
	icon_button.disabled = !supported
	icon_button.position = Vector3(left + size.y / 2, 0, 0)
	add_child(icon_button)
	icon_button.label_node.modulate = Color(1, 1, 1, alpha)

	var text_left = left + size.y + 0.006
	var text_width = size.x / 2 - ACTION_WIDTH - 0.006 - text_left

	var name_label = DeviceUtils.make_label(NAME_SIZE, alpha)
	name_label.text = DeviceUtils.fit_text(display_name, NAME_SIZE, text_width)
	name_label.position = Vector3(text_left, 0.0045, front)
	add_child(name_label)

	_state_label = DeviceUtils.make_label(STATE_SIZE, 0.6 * alpha)
	_state_label.position = Vector3(text_left, -0.0075, front)
	_state_label.set_meta("max_width", text_width)
	add_child(_state_label)
	_set_state_text("")

	_place_button = ButtonScene.instantiate()
	_place_button.size = Vector3(ACTION_WIDTH, size.y * 0.8, size.z)
	_place_button.font_size = 9
	_place_button.label = "Place"
	_place_button.position = Vector3(size.x / 2 - ACTION_WIDTH / 2, 0, 0)
	add_child(_place_button)

	_status = DeviceUtils.make_label(8, 1.0, HORIZONTAL_ALIGNMENT_RIGHT)
	_status.position = Vector3(size.x / 2 - 0.002, 0, front)
	add_child(_status)

	if supported:
		icon_button.on_button_up.connect(func(): on_place.emit())
		_place_button.on_button_up.connect(func(): on_place.emit())

	_update_action()
	_watch()

func _update_action():
	_place_button.visible = supported && !placed
	_place_button.disabled = !_place_button.visible
	_status.visible = supported && placed
	_status.text = "Placed"
	_status.modulate = PLACED_COLOR

func _set_state_text(state_text: String):
	var parts = []
	if !supported:
		parts.append("Not supported")
	elif state_text != "":
		parts.append(state_text)
	if context != "":
		parts.append(context)

	_state_label.text = DeviceUtils.fit_text(" · ".join(parts), STATE_SIZE, _state_label.get_meta("max_width"))

func _enter_tree():
	if is_node_ready():
		_watch()

func _exit_tree():
	_stop_watching()

func _watch():
	_stop_watching()

	if !supported || !HomeApi.has_connected():
		return

	_unwatch = HomeApi.watch_state(entity_id, _on_state)
	_on_state(await HomeApi.get_state(entity_id))

func _stop_watching():
	if _unwatch is Callable:
		_unwatch.call()
	_unwatch = null

func _on_state(data):
	if !is_inside_tree():
		return
	_set_state_text(DeviceUtils.format_state(entity_id, data))
