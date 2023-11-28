extends Node

const Initiator = preload("./initiator.gd")

var initiator: Initiator
var ray: RayCast3D

var timespan_click = 400.0

var last_collided: Object = null
var is_pressed := false
var is_grabbed := false
var time_pressed := 0.0
var moved := false
var click_point := Vector3.ZERO

func _init(initiator: Initiator, ray: RayCast3D):
	self.initiator = initiator
	self.ray = ray

func _ready():
	initiator.on_press.connect(_on_pressed)
	initiator.on_release.connect(_on_released)

func _physics_process(_delta):
	_handle_enter_leave()
	_handle_move()

func _handle_move():
	var time_passed = Time.get_ticks_msec() - time_pressed
	if time_passed <= timespan_click || (is_pressed == false && is_grabbed == false):
		return

	moved = true

	# reset if last_collided gets deleted
	if is_instance_valid(last_collided) == false:
		last_collided = null
		return

	if is_pressed:
		_emit_event("press_move", last_collided )
		
	if is_grabbed:
		_emit_event("grab_move", last_collided )

func _handle_enter_leave():
	var collider = ray.get_collider()

	if collider == last_collided || is_grabbed || is_pressed:
		return

	_emit_event("ray_enter", collider )
	_emit_event("ray_leave", last_collided )

	last_collided = collider

func _on_pressed(type: Initiator.EventType):
	var collider = ray.get_collider()

	if collider == null:
		return

	match type:
		Initiator.EventType.TRIGGER:
			is_pressed = true
			time_pressed = Time.get_ticks_msec()
			click_point = ray.get_collision_point()
			_emit_event("press_down", collider )
		Initiator.EventType.GRIP:
			is_grabbed = true
			click_point = ray.get_collision_point()
			_emit_event("grab_down", collider )

func _on_released(type: Initiator.EventType):
	match type:
		Initiator.EventType.TRIGGER:
			if is_pressed:
				if moved == false:
					_emit_event("click", last_collided )
				_emit_event("press_up", last_collided )
				is_pressed = false
				last_collided = null
				moved = false
		Initiator.EventType.GRIP:
			if is_grabbed:
				_emit_event("grab_up", last_collided )
				is_grabbed = false
				last_collided = null
				moved = false

func _emit_event(type: String, target):
	var event = EventPointer.new()
	event.initiator = initiator
	event.target = target
	event.ray = ray

	EventSystem.emit(type, event)
