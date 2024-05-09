extends Entity

const Entity = preload ("../entity.gd")
const color_wheel_img := preload ("res://assets/canvas.png")

@export var color_off = Color(0.23, 0.23, 0.23)
@export var color_on = Color(1.0, 0.85, 0.0)

@onready var lightbulb = $Lightbulb
@onready var slider: Slider3D = $Slider
@onready var color_wheel = $ColorWheel
@onready var color_puck = $ColorWheel/Puck
@onready var modes = $Modes
@onready var mode_next = $Modes/Next
@onready var mode_before = $Modes/Previous
@onready var mode_label = $Modes/Label
@onready var snap_sound = $SnapSound

var active = R.state(false)
var brightness = R.state(0) # 0-255
var color = R.state(color_on)
var color_supported = false

# Called when the node enters the scene tree for the first time.
func _ready():
	super()

	if HomeApi.has_connected() == false:
		await HomeApi.on_connect
	
	icon.value = "lightbulb"
	var stateInfo = await HomeApi.get_state(entity_id)
	set_state(stateInfo)

	if stateInfo.has("attributes")&&stateInfo["attributes"].has("effect_list")&&stateInfo["attributes"]["effect_list"].size() > 0:
		if stateInfo["attributes"].has("effect")&&stateInfo["attributes"]["effect"] != null:
			mode_label.text = stateInfo["attributes"]["effect"]

		mode_next.on_button_down.connect(func():
			var index=stateInfo["attributes"]["effect_list"].find(stateInfo["attributes"]["effect"])
			if index == - 1:
				index=0
			else:
				index=(index + 1) % stateInfo["attributes"]["effect_list"].size()

			mode_label.text=stateInfo["attributes"]["effect_list"][index]

			HomeApi.set_state(entity_id, "on", {"effect": stateInfo["attributes"]["effect_list"][index]})
		)

		mode_before.on_button_down.connect(func():
			var index=stateInfo["attributes"]["effect_list"].find(stateInfo["attributes"]["effect"])
			if index == - 1:
				index=0
			else:
				index=(index - 1) % stateInfo["attributes"]["effect_list"].size()

			mode_label.text=stateInfo["attributes"]["effect_list"][index]

			HomeApi.set_state(entity_id, "on", {"effect": stateInfo["attributes"]["effect_list"][index]})
		)
	else:
		remove_child(modes)

	if stateInfo.has("attributes")&&stateInfo["attributes"].has("supported_color_modes")&&stateInfo["attributes"]["supported_color_modes"].has("rgb"):
		color_wheel.get_node("Clickable").on_press_down.connect(func(event: EventPointer):
			var target_point=color_wheel.to_local(event.ray.get_collision_point())

			var delta=Vector2(target_point.x, target_point.z) * (1.0 / 0.08)
			if delta.length() > 1:
				delta=delta.normalized()
			
			var picked_color=color_wheel_img.get_image().get_pixel((delta.x * 0.5 + 0.5) * 1000, (delta.y * 0.5 + 0.5) * 1000)

			color_puck.material_override.albedo_color=picked_color
			color_puck.position=Vector3(target_point.x, color_puck.position.y, target_point.z)

			var attributes={
				"rgb_color": [int(picked_color.r * 255), int(picked_color.g * 255), int(picked_color.b * 255)],
			}

			snap_sound.play()

			HomeApi.set_state(entity_id, "on", attributes)
		)
		color_supported = true
	else:
		remove_child(color_wheel)

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

	slider.on_value_changed.connect(func(new_value):
		var value=new_value / 100 * 255
		HomeApi.set_state(entity_id, "on" if active.value else "off", {"brightness": int(value)})
	)

func set_state(stateInfo):
	if active.value == false&&stateInfo["state"] == "off":
		return

	var attributes = stateInfo["attributes"]

	active.value = stateInfo["state"] == "on"

	if attributes.has("brightness")&&attributes["brightness"] != null:
		brightness.value = attributes["brightness"]
		slider.value = attributes["brightness"] / 255.0 * 100

	if attributes.has("rgb_color")&&attributes["rgb_color"] != null:
		color.value = Color(attributes["rgb_color"][0] / 255.0, attributes["rgb_color"][1] / 255.0, attributes["rgb_color"][2] / 255.0, 1)

	var tween = create_tween()

	var target_color = color_off

	if active.value:
		if brightness.value == null:
			target_color = color.value if color_supported else color_on
		else:
			target_color = color_off.lerp(color.value if color_supported else color_on, brightness.value / 255.0)

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
