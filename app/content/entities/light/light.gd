extends Entity

const Entity = preload ("../entity.gd")

@export var color_off = Color(0.23, 0.23, 0.23)
@export var color_on = Color(1.0, 0.85, 0.0)

@onready var slider: Slider3D = $Slider
@onready var color_wheel = $ColorWheel
@onready var modes: Select3D = $Modes
@onready var snap_sound = $SnapSound
@onready var settings = $Settings
@onready var movable = $Movable
@onready var light_radiation = $light/LightRadiation
@onready var glass_mesh: MeshInstance3D = $light/Sphere
@onready var rod_mesh: MeshInstance3D = $light/Cylinder_001

# Per-instance copies so tweening one light doesn't recolour every bulb sharing the .tres
var glass_material: StandardMaterial3D
var rod_material: StandardMaterial3D
var visual_tween: Tween

# A tap is a finger poking into the bulb and backing out the way it came, within a short window.
# Passing through the bulb (e.g. reaching for the slider) exits on the far side and is ignored.
const TAP_MIN_MS = 40.0
const TAP_MAX_MS = 600.0
var touch_start_time = 0.0
var touch_entry_dir = Vector3.ZERO
var touch_last_dir = Vector3.ZERO
var touch_active = false

var active = R.state(false)
var brightness = R.state(0) # 0-255
var color = R.state(color_on)
var show_color_wheel = R.state(true)
var color_wheel_supported = R.state(false)
var show_brightness = R.state(true)
var show_modes = R.state(true)
var modes_supported = R.state(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	super()

	glass_material = glass_mesh.material_override.duplicate()
	glass_mesh.material_override = glass_material
	rod_material = rod_mesh.material_override.duplicate()
	rod_mesh.material_override = rod_material

	# Start in the "off" look; set_state skips off->off updates, so this must be applied up front.
	_apply_visuals(color_off, false, false)

	if HomeApi.has_connected() == false:
		await HomeApi.on_connect
	
	icon.value = "lightbulb"
	var stateInfo = await HomeApi.get_state(entity_id)
	set_state(stateInfo)

	remove_child(settings)

	R.effect(func(_arg):
		if show_settings.value:
			add_child(settings)
		elif settings.is_inside_tree():
			remove_child(settings)
			camera_follower.reset()
			App.house.save_all_entities()
	)

	R.effect(func(_arg):
		if show_color_wheel.value&&color_wheel_supported.value:
			add_child(color_wheel)
		else:
			remove_child(color_wheel)
	)

	R.effect(func(_arg):
		if show_brightness.value:
			add_child(slider)
		else:
			remove_child(slider)
	)

	R.effect(func(_arg):
		if show_modes.value&&modes_supported.value:
			add_child(modes)
		else:
			remove_child(modes)
	)

	modes.on_select.connect(_on_mode_selected)

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

	color_wheel.on_color_changed.connect(func(new_color):
		if color.value == new_color:
			return

		var attributes={
			"rgb_color": [int(new_color.r * 255), int(new_color.g * 255), int(new_color.b * 255)],
		}

		snap_sound.play()

		print("set color", new_color, attributes["rgb_color"])

		HomeApi.set_state(entity_id, "on", attributes)
	)

	slider.on_value_changed.connect(func(new_value):
		var value=new_value / 100 * 255
		HomeApi.set_state(entity_id, "on" if active.value else "off", {"brightness": int(value)})
	)

func set_state(stateInfo):
	if stateInfo == null:
		return

	var attributes = stateInfo.get("attributes", {})

	update_capabilities(attributes)

	active.value = stateInfo["state"] == "on"

	if attributes.has("brightness")&&attributes["brightness"] != null:
		brightness.value = attributes["brightness"]
		slider.value = attributes["brightness"] / 255.0 * 100

	if attributes.has("rgb_color")&&attributes["rgb_color"] != null:
		color.value = Color(attributes["rgb_color"][0] / 255.0, attributes["rgb_color"][1] / 255.0, attributes["rgb_color"][2] / 255.0, 1)
		print("got color", color.value, attributes["rgb_color"])
		color_wheel.color = color.value

	var target_color = color_off

	if active.value:
		if brightness.value == null:
			target_color = color.value if show_color_wheel.value else color_on
		else:
			target_color = color_off.lerp(color.value if show_color_wheel.value else color_on, brightness.value / 255.0)

	_apply_visuals(target_color, active.value, true)

func _apply_visuals(target_color: Color, is_on: bool, animate: bool):
	icon_color.value = target_color

	var glass_color = Color(target_color.r, target_color.g, target_color.b, 0.5)
	var radiation_color = Color(target_color.r, target_color.g, target_color.b, 1.0 if is_on else 0.0)

	if visual_tween != null && visual_tween.is_valid():
		visual_tween.kill()

	if not animate:
		glass_material.albedo_color = glass_color
		rod_material.albedo_color = target_color
		light_radiation.modulate = radiation_color
		return

	visual_tween = create_tween()
	visual_tween.set_parallel(true)
	visual_tween.tween_property(glass_material, "albedo_color", glass_color, 0.3)
	visual_tween.tween_property(rod_material, "albedo_color", target_color, 0.3)
	visual_tween.tween_property(light_radiation, "modulate", radiation_color, 0.3)

func _touch_dir(event: EventTouch) -> Vector3:
	var center = $TouchArea/CollisionShape3D.global_position
	if event.fingers.is_empty():
		return Vector3.ZERO
	var sum = Vector3.ZERO
	for finger in event.fingers:
		sum += finger.area.global_position - center
	return sum / event.fingers.size()

func _on_touch_enter(event: EventTouch):
	if event.target != $TouchArea:
		return
	event.bubbling = false

	if touch_active:
		return

	touch_active = true
	touch_start_time = Time.get_ticks_msec()
	touch_entry_dir = _touch_dir(event)
	touch_last_dir = touch_entry_dir

func _on_touch_move(event: EventTouch):
	if event.target != $TouchArea:
		return
	event.bubbling = false

	if event.fingers.size() > 0:
		touch_last_dir = _touch_dir(event)

func _on_touch_leave(event: EventTouch):
	if event.target != $TouchArea:
		return
	event.bubbling = false

	if not touch_active:
		return
	touch_active = false

	var duration = Time.get_ticks_msec() - touch_start_time
	if duration < TAP_MIN_MS||duration > TAP_MAX_MS:
		return

	# Exited on the opposite side from where it entered -> finger passed through, not a tap.
	if touch_entry_dir.dot(touch_last_dir) < 0:
		return

	snap_sound.play()
	_toggle()

## Detects effect and colour support from the entity attributes. Runs on every state update
## so lights whose state arrives after spawn still get their modes and colour wheel.
func update_capabilities(attributes: Dictionary):
	# Only write on change: writes always notify effects, which would re-add/remove child nodes.
	var effect_list = attributes.get("effect_list")
	var has_modes = effect_list is Array&&effect_list.size() > 0
	if modes_supported.value != has_modes:
		modes_supported.value = has_modes

	if has_modes:
		var options = {}
		for effect in effect_list:
			options[effect] = effect

		if modes.options != options:
			modes.options = options

		# Setting `selected` emits on_select, which would send a state change,
		# so only preselect the current effect before the handler is connected.
		if attributes.get("effect") != null&&not modes.on_select.is_connected(_on_mode_selected):
			modes.selected = attributes["effect"]

	var color_modes = attributes.get("supported_color_modes")
	var has_rgb = color_modes is Array&&color_modes.has("rgb")
	if color_wheel_supported.value != has_rgb:
		color_wheel_supported.value = has_rgb

func _on_mode_selected(option):
	HomeApi.set_state(entity_id, "on", {"effect": option})

func _on_click(event):
	if event.target == self:
		snap_sound.play()
		_toggle()

func quick_action():
	_toggle()

func _toggle():
	HomeApi.set_state(entity_id, "off" if active.value else "on")

func get_options():
	return {
		"color_wheel": show_color_wheel.value,
		"brightness": show_brightness.value,
		"modes": show_modes.value,
	}

func set_options(options):
	if options.has("color_wheel"): show_color_wheel.value = options["color_wheel"]
	if options.has("brightness"): show_brightness.value = options["brightness"]
	if options.has("modes"): show_modes.value = options["modes"]