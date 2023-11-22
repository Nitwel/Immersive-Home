extends RayCast3D

@export var is_right: bool = true

var controller: XRController3D
var timespan_click = 200.0

var last_collided: Object = null
var is_pressed := false
var is_grabbed := false
var time_pressed := 0.0
var moved := false
var click_point := Vector3.ZERO

func _ready():
	controller = get_parent()
	assert(controller is XRController3D, "XRController3D is not found in parent")

	controller.button_pressed.connect(_on_button_pressed)
	controller.button_released.connect(_on_button_released)

func _physics_process(_delta):
	_handle_enter_leave()
	_handle_move()

func _handle_move():
	var time_passed = Time.get_ticks_msec() - time_pressed
	if time_passed <= timespan_click || (is_pressed == false && is_grabbed == false):
		return

	moved = true

	if is_pressed:
		_emit_event("press_move", last_collided )
		
	if is_grabbed:
		_emit_event("grab_move", last_collided )

func _handle_enter_leave():
	var collider = get_collider()

	if collider == last_collided || is_grabbed || is_pressed:
		return

	_emit_event("ray_enter", collider )
	_emit_event("ray_leave", last_collided )

	last_collided = collider

func _on_button_pressed(button: String):
	var collider = get_collider()

	if collider == null:
		return

	match button:
		"trigger_click":
			is_pressed = true
			time_pressed = Time.get_ticks_msec()
			click_point = get_collision_point()
			_emit_event("press_down", collider )
		"grip_click":
			is_grabbed = true
			click_point = get_collision_point()
			_emit_event("grab_down", collider )

func _on_button_released(button: String):
	if last_collided == null:
		return

	match button:
		"trigger_click":
			if is_pressed:
				if moved == false:
					_emit_event("click", last_collided )
				_emit_event("press_up", last_collided )
				is_pressed = false
				last_collided = null
				moved = false
		"grip_click":
			if is_grabbed:
				_emit_event("grab_up", last_collided )
				is_grabbed = false
				last_collided = null
				moved = false

func _emit_event(type: String, target: Object):
	var event = EventRay.new()
	event.controller = controller
	event.target = target
	event.ray = self
	event.is_right_controller = is_right

	EventSystem.emit(type, event)