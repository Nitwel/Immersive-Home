extends Node
## Logic for the raycast to interact with objects

const Initiator = preload ("./initiator.gd")

var initiator: Initiator
var ray: RayCast3D

var timespan_click = 400.0

## Node currently hovered by the ray
var last_collided: Object = null

## Trigger and grip are tracked separately so that holding both at the same time
## (e.g. a hand pinching with index and middle finger) can't end one of them on
## the wrong target or swallow its release event.
var is_pressed := false
var press_target: Object = null
var time_pressed := 0.0
var moved := false

var is_grabbed := false
var grab_target: Object = null

var click_point := Vector3.ZERO

func _init(initiator: Initiator, ray: RayCast3D):
	self.initiator = initiator
	self.ray = ray

func _physics_process(_delta):
	_handle_enter_leave()
	_handle_move()

func _handle_move():
	if is_pressed:
		if Time.get_ticks_msec() - time_pressed > timespan_click:
			moved = true
			if is_instance_valid(press_target):
				_emit_event("press_move", press_target)

	if is_grabbed&&is_instance_valid(grab_target):
		_emit_event("grab_move", grab_target)

func _handle_enter_leave():
	var collider = ray.get_collider()

	if collider == last_collided||is_grabbed||is_pressed:
		return

	_emit_event("ray_enter", collider)
	_emit_event("ray_leave", last_collided)

	last_collided = collider

func pressed(type: Initiator.EventType):
	var collider = ray.get_collider()

	if collider == null:
		return

	match type:
		Initiator.EventType.TRIGGER:
			if is_pressed:
				return
			is_pressed = true
			press_target = collider
			moved = false
			time_pressed = Time.get_ticks_msec()
			click_point = ray.get_collision_point()
			_emit_event("press_down", collider)
		Initiator.EventType.GRIP:
			if is_grabbed:
				return
			is_grabbed = true
			grab_target = collider
			click_point = ray.get_collision_point()
			_emit_event("grab_down", collider)

func released(type: Initiator.EventType):
	match type:
		Initiator.EventType.TRIGGER:
			if !is_pressed:
				return
			var target = press_target
			is_pressed = false
			press_target = null
			if moved == false:
				_emit_event("click", target)
			_emit_event("press_up", target)
			moved = false
			_reset_hover()
		Initiator.EventType.GRIP:
			if !is_grabbed:
				return
			var target = grab_target
			is_grabbed = false
			grab_target = null
			_emit_event("grab_up", target)
			_reset_hover()

## Releases trigger and grip, e.g. when the hand/controller stops being tracked.
func release_all():
	released(Initiator.EventType.TRIGGER)
	released(Initiator.EventType.GRIP)

func _reset_hover():
	# Re-evaluate the hover once nothing is held anymore, so ray_enter fires again
	if !is_pressed&&!is_grabbed:
		last_collided = null

func _emit_event(type: String, target):
	var event = EventPointer.new()
	event.initiator = initiator
	# last_collided can be freed while hovered/pressed (e.g. UI rebuilt on click);
	# EventPointer.target is typed Node and rejects freed instances.
	event.target = target if is_instance_valid(target) else null
	event.ray = ray

	EventSystem.emit(type, event)
