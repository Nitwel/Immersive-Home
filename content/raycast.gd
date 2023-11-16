extends Node3D

@onready var _controller := XRHelpers.get_xr_controller(self)
@export var ray: RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready():
	_controller.button_pressed.connect(_on_button_pressed)
	_controller.button_released.connect(_on_button_released)

var _last_collided: Object = null
var _is_pressed := false
var _is_grabbed := false
var _moved := false
var _click_point := Vector3.ZERO

func _physics_process(delta):
	_handle_enter_leave()
	_handle_move()

func _handle_move():
	if _is_pressed == false && _is_grabbed == false:
		return

	var distance = ray.get_collision_point().distance_to(_click_point)

	if _moved || distance > 0.02:
		if _is_pressed:
			_call_fn(_last_collided, "_on_press_move")
			_moved = true
		if _is_grabbed:
			_call_fn(_last_collided, "_on_grab_move")
			_moved = true

func _handle_enter_leave():
	var collider = ray.get_collider()

	if collider == _last_collided || _is_grabbed || _is_pressed:
		return

	_call_fn(collider, "_on_ray_enter")
	_call_fn(_last_collided, "_on_ray_leave")

	_last_collided = collider

func _on_button_pressed(button):
	var collider = ray.get_collider()

	if collider == null:
		return

	match button:
		"trigger_click":
			_is_pressed = true
			_click_point = ray.get_collision_point()
			_call_fn(collider, "_on_press_down")
		"grip_click":
			_is_grabbed = true
			_click_point = ray.get_collision_point()
			_call_fn(collider, "_on_grab_down")

func _on_button_released(button):
	if _last_collided == null:
		return

	match button:
		"trigger_click":
			if _is_pressed:
				if _moved == false:
					_call_fn(_last_collided, "_on_click")
				_call_fn(_last_collided, "_on_press_up")
				_is_pressed = false
				_moved = false
		"grip_click":
			if _is_grabbed:
				_call_fn(_last_collided, "_on_grab_up")
				_is_grabbed = false
				_moved = false

func _call_fn(collider: Object, fn_name: String, node: Node3D = null, event = null):
	if collider == null:
		return

	if node == null:
		node = collider
		event = {
			"controller": _controller,
			"ray": ray,
			"target": collider,
		}

	if node.has_method(fn_name):
		var result = node.call(fn_name, event)

		if result != null && result is Dictionary:
			result.merge(event, true)

		if result != null && result is bool && result == false:
			# Stop the event from bubbling up
			return

	for child in node.get_children():
		if child is Function && child.has_method(fn_name):
			child.call(fn_name, event)
			

	var parent = node.get_parent()

	if parent != null && parent is Node3D:
		_call_fn(collider, fn_name, parent, event)
