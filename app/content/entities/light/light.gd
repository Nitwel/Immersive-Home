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

var state = true
var brightness = 0 # 0-255
var color = color_on
var color_supported = false

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	
	icon.value = "lightbulb"
	var stateInfo = await HomeApi.get_state(entity_id)
	set_state(stateInfo["state"] == "on", stateInfo["attributes"])

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

			print("delta", delta)
			
			var color=color_wheel_img.get_image().get_pixel((delta.x * 0.5 + 0.5) * 1000, (delta.y * 0.5 + 0.5) * 1000)

			print("color", color)

			color_puck.material_override.albedo_color=color
			color_puck.position=Vector3(target_point.x, color_puck.position.y, target_point.z)

			var attributes={
				"rgb_color": [int(color.r * 255), int(color.g * 255), int(color.b * 255)],
			}

			HomeApi.set_state(entity_id, "on", attributes)
			set_state(state, attributes)
		)
		color_supported = true
	else:
		remove_child(color_wheel)

	await HomeApi.watch_state(entity_id, func(new_state):
		if (new_state["state"] == "on") == state:
			return
		set_state(new_state["state"] == "on", new_state["attributes"])
	)

	slider.on_value_changed.connect(func(new_value):
		var value=new_value / 100 * 255
		HomeApi.set_state(entity_id, "on" if state else "off", {"brightness": int(value)})
		set_state(state, {"brightness": value})
	)

func set_state(new_state: bool, attributes={}):
	if state == false&&new_state == false:
		return

	state = new_state

	if attributes.has("brightness"):
		brightness = attributes["brightness"]

	if attributes.has("rgb_color")&&attributes["rgb_color"] != null:
		color = Color(attributes["rgb_color"][0] / 255.0, attributes["rgb_color"][1] / 255.0, attributes["rgb_color"][2] / 255.0, 1)

	var tween = create_tween()

	var target_color = color_off

	if state:
		if brightness == null:
			target_color = color if color_supported else color_on
		else:
			target_color = color_off.lerp(color if color_supported else color_on, brightness / 255.0)

	icon_color.value = target_color
	tween.tween_property(lightbulb, "material_override:albedo_color", target_color, 0.3)

func _on_click(event):
	if event.target == self:
		var attributes = {}

		if !state&&brightness != null:
			attributes["brightness"] = int(brightness)

		HomeApi.set_state(entity_id, "on" if !state else "off", attributes)
		set_state(!state, attributes)

func quick_action():
	var attributes = {}

	if !state&&brightness != null:
		attributes["brightness"] = int(brightness)

	HomeApi.set_state(entity_id, "on" if !state else "off", attributes)
	set_state(!state, attributes)