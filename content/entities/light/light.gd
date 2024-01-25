extends StaticBody3D

@export var entity_id = "switch.plug_printer_2"
@export var color_off = Color(0.23, 0.23, 0.23)
@export var color_on = Color(1.0, 0.85, 0.0)

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var slider: Slider3D = $Slider

var state = true
var brightness = 0 # 0-255

# Called when the node enters the scene tree for the first time.
func _ready():
	var stateInfo = await HomeApi.get_state(entity_id)
	set_state(stateInfo["state"] == "on")

	await HomeApi.watch_state(entity_id, func(new_state):
		if (new_state["state"] == "on") == state:
			return
		set_state(new_state["state"] == "on")
	)

	slider.on_value_changed.connect(func(new_value):
		var value = new_value / 100 * 255
		HomeApi.set_state(entity_id, "on" if state else "off", {"brightness": int(value)})
		set_state(state, value)
	)

func set_state(new_state: bool, new_brightness = null):
	if state == false && new_state == false:
		return

	state = new_state
	brightness = new_brightness

	if state:
		if brightness == null:
			animation.speed_scale = 1
			animation.play_backwards("light")
		else:
			var duration = animation.get_animation("light").length
			animation.speed_scale = 0
			animation.seek(lerpf(0, duration, 1 - (brightness / 255.0)), true)
	else:
		animation.speed_scale = 1
		animation.play("light")


func _on_click(event):
	if event.target == self:
		var attributes = {}

		if !state && brightness != null:
			attributes["brightness"] = int(brightness)

		HomeApi.set_state(entity_id, "on" if !state else "off", attributes)
		set_state(!state, brightness)