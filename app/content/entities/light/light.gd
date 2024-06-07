extends Entity

const Entity = preload ("../entity.gd")

@export var color_off = Color(0.23, 0.23, 0.23)
@export var color_on = Color(1.0, 0.85, 0.0)

@onready var lightbulb = $Lightbulb
@onready var slider: Slider3D = $Slider
@onready var color_wheel = $ColorWheel
@onready var modes: Select3D = $Modes
@onready var snap_sound = $SnapSound
@onready var settings = $Settings
@onready var movable = $Movable

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

	if stateInfo.has("attributes")&&stateInfo["attributes"].has("effect_list")&&stateInfo["attributes"]["effect_list"].size() > 0:
		modes_supported.value = true

		if stateInfo["attributes"].has("effect")&&stateInfo["attributes"]["effect"] != null:
			modes.selected = stateInfo["attributes"]["effect"]

		var options = {}

		for effect in stateInfo["attributes"]["effect_list"]:
			options[effect] = effect

		modes.options = options

		modes.on_select.connect(func(option):
			HomeApi.set_state(entity_id, "on", {"effect": option})
		)

	if stateInfo.has("attributes")&&stateInfo["attributes"].has("supported_color_modes")&&stateInfo["attributes"]["supported_color_modes"].has("rgb"):
		color_wheel_supported.value = true

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

	if active.value == false&&stateInfo["state"] == "off":
		return

	var attributes = stateInfo["attributes"]

	active.value = stateInfo["state"] == "on"

	if attributes.has("brightness")&&attributes["brightness"] != null:
		brightness.value = attributes["brightness"]
		slider.value = attributes["brightness"] / 255.0 * 100

	if attributes.has("rgb_color")&&attributes["rgb_color"] != null:
		color.value = Color(attributes["rgb_color"][0] / 255.0, attributes["rgb_color"][1] / 255.0, attributes["rgb_color"][2] / 255.0, 1)
		print("got color", color.value, attributes["rgb_color"])
		color_wheel.color = color.value

	var tween = create_tween()

	var target_color = color_off

	if active.value:
		if brightness.value == null:
			target_color = color.value if show_color_wheel.value else color_on
		else:
			target_color = color_off.lerp(color.value if show_color_wheel.value else color_on, brightness.value / 255.0)

	icon_color.value = target_color
	tween.tween_property(lightbulb, "material_override:albedo_color", target_color, 0.3)

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
