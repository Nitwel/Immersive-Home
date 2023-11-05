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

func _get_event_data():
	return {
		"controller": _controller,
		"ray": ray,
	}

func _handle_move():
	var distance = ray.get_collision_point().distance_to(_click_point)

	if distance > 0.01:
		if _is_pressed:
			_call_fn("_on_press_move")
			_moved = true
		if _is_grabbed:
			_call_fn("_on_grab_move")
			_moved = true

func _handle_enter_leave():
	var collider = ray.get_collider()

	if collider == _last_collided:
		return

	if _last_collided != null && _last_collided.has_method("_on_ray_enter"):
		_last_collided._on_ray_enter(_get_event_data())

	if collider != null && collider.has_method("_on_ray_leave"):
		collider._on_ray_leave(_get_event_data())

	_last_collided = collider

func _on_button_pressed(button):
	var collider = ray.get_collider()

	if collider == null:
		return

	match button:
		"trigger_click":
			_is_pressed = true
			_click_point = ray.get_collision_point()
			_call_fn("_on_press_down")
		"grip_click":
			_is_grabbed = true
			_click_point = ray.get_collision_point()
			_call_fn("_on_grab_down")

func _on_button_released(button):
	var collider = ray.get_collider()

	if collider == null:
		return

	match button:
		"trigger_click":
			if _is_pressed:
				if _moved == false:
					_call_fn("_on_click")
				_call_fn("_on_press_up")
				_is_pressed = false
				_moved = false
		"grip_click":
			if _is_grabbed:
				_call_fn("_on_grab_up")
				_is_grabbed = false
				_moved = false

func _call_fn(fn_name: String):
	print("call_fn", fn_name)
	var collider = ray.get_collider()

	if collider == null:
		return
	
	if collider.has_method(fn_name):
		collider.call(fn_name, _get_event_data())
