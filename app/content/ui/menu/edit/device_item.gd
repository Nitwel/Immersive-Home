@tool
extends Container3D
## One row in the edit menu's device list: icon, name, number of placeable
## entities and a live dot for lights, switches and media players.

signal on_select()

const DeviceUtils = preload ("./device_utils.gd")
const ButtonScene = preload ("res://content/ui/components/button/button.tscn")

const FONT_SIZE = 10
const DOT_COLOR = Color(0.98, 0.78, 0.42)

var device: Dictionary
var display_name: String

var selected := false:
	set(value):
		selected = value
		if is_node_ready():
			button.active = selected

var button: Button3D
var _dot: MeshInstance3D
var _unwatch = null

func _init(device_view: Dictionary, name_text: String, item_size: Vector3):
	device = device_view
	display_name = name_text
	size = item_size

func _ready():
	button = ButtonScene.instantiate()
	button.label = ""
	button.size = size
	add_child(button)

	# Put everything on the button's body so it moves with the press animation,
	# like the button's own label. Its front face is at size.z / 2 in body space.
	var face: Node3D = button.body
	var front = size.z / 2 + 0.001
	var left = -size.x / 2

	var icon = DeviceUtils.make_label(16, 1.0, HORIZONTAL_ALIGNMENT_CENTER, true)
	icon.text = device["icon"]
	icon.position = Vector3(left + 0.012, 0, front)
	face.add_child(icon)

	var count = DeviceUtils.make_label(8, 0.55, HORIZONTAL_ALIGNMENT_RIGHT)
	count.text = str(device["supported_count"])
	count.position = Vector3(size.x / 2 - 0.006, 0, front)
	face.add_child(count)

	var name_left = left + 0.025
	var name_width = (size.x / 2 - 0.006 - DeviceUtils.text_width(count.text, 8) - 0.005) - name_left
	var label = DeviceUtils.make_label(FONT_SIZE)
	label.text = DeviceUtils.fit_text(display_name, FONT_SIZE, name_width)
	label.position = Vector3(name_left, 0, front)
	face.add_child(label)

	_dot = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.0016
	sphere.height = 0.0032
	_dot.mesh = sphere
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = DOT_COLOR
	_dot.material_override = material
	_dot.position = Vector3(left + 0.019, 0.0065, front)
	_dot.visible = false
	face.add_child(_dot)

	button.on_button_up.connect(func():
		on_select.emit()
		# A plain button releases its active state on button up; keep the selection visible.
		(func(): button.active=selected).call_deferred()
	)

	button.active = selected
	_watch()

func _enter_tree():
	if is_node_ready():
		_watch()

func _exit_tree():
	_stop_watching()

func _watch():
	_stop_watching()

	var entity_id = device["main_entity"]
	if entity_id == null || !HomeApi.has_connected():
		return

	_unwatch = HomeApi.watch_state(entity_id, _update_dot)
	_update_dot(await HomeApi.get_state(entity_id))

func _stop_watching():
	if _unwatch is Callable:
		_unwatch.call()
	_unwatch = null

func _update_dot(data):
	if !is_inside_tree() || data == null || typeof(data) != TYPE_DICTIONARY:
		return

	var domain = DeviceUtils.domain_of(device["main_entity"])
	_dot.visible = DeviceUtils.LIVE_DOMAINS[domain].has(str(data.get("state", "")))
