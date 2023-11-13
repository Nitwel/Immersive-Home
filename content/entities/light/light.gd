extends StaticBody3D

@export var entity_id = "switch.plug_printer_2"
@onready var sprite: AnimatedSprite3D = $Icon
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var shape = $CSGCombiner3D
@onready var rod_top = $RodTop
@onready var rod_bottom = $RodBottom
@onready var slider_knob = $Knob
var state = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var stateInfo = await HomeAdapters.adapter.get_state(entity_id)
	set_state(stateInfo["state"] == "on")

	await HomeAdapters.adapter.watch_state(entity_id, func(new_state):
		if (new_state["state"] == "on") == state:
			return
		set_state(new_state["state"] == "on")
	)

func set_state(state: bool):
	self.state = state
	if state:
		animation.play_backwards("light")
	else:
		animation.play("light")

func _on_click(event):
	if event.target == self:
		HomeAdapters.adapter.set_state(entity_id, "on" if !state else "off")
		set_state(!state)
	else:
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

	HomeAdapters.adapter.set_state(entity_id, "on" if state else "off", {"brightness_pct": int(ratio * 100)})
