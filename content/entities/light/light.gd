extends StaticBody3D

@export var entity_id = "switch.plug_printer_2"
@export var color_off = Color(0.23, 0.23, 0.23)
@export var color_on = Color(1.0, 0.85, 0.0)

@onready var shape = $CSGCombiner3D
@onready var rod_top = $RodTop
@onready var rod_bottom = $RodBottom
@onready var slider_knob = $Knob
var state = false
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

func set_state(state: bool, brightness = null):
	print("set_state ", state, brightness)
	self.state = state
	self.brightness = brightness

	if state:
		if brightness == null:
			shape.material_override.albedo_color = color_on
		else:
			shape.material_override.albedo_color = color_off.lerp(color_on, brightness / 255.0)
	else:
			shape.material_override.albedo_color = color_off



func _on_click(event):
	if event.target == self:
		var attributes = {}

		if !state && brightness != null:
			attributes["brightness"] = int(brightness)

		HomeApi.set_state(entity_id, "on" if !state else "off", attributes)
		set_state(!state, brightness)
	else:
		_on_clickable_on_click(event)

func _on_press_move(event):
	if event.target != self:
		_on_clickable_on_click(event)
		

func _on_request_completed():
	pass


func _on_clickable_on_click(event):
	var click_pos: Vector3 = to_local(event.ray.get_collision_point())
	var vec_bottom_to_top = rod_top.position - rod_bottom.position

	var length_click = click_pos.y - rod_bottom.position.y
	var length_total = vec_bottom_to_top.y

	var ratio = length_click / length_total

	var new_pos = rod_bottom.position.lerp(rod_top.position, ratio)

	slider_knob.position = new_pos

	HomeApi.set_state(entity_id, "on" if state else "off", {"brightness": int(ratio * 255)})
	set_state(state, ratio * 255)
