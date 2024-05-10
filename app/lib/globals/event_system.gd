extends Node

## Prefix for the function names to be called
const FN_PREFIX = "_on_"
## Prefix for the signal names to be emitted
const SIGNAL_PREFIX = "on_"
## Tick rate for the slow tick event
const SLOW_TICK = 0.1

## Emitted when a node is clicked
signal on_click(event: EventPointer)

## Emitted when a node is pressed down
signal on_press_down(event: EventPointer)
## Emitted when a node is moved while pressed
signal on_press_move(event: EventPointer)
## Emitted when a node is released
signal on_press_up(event: EventPointer)

## Emitted when a node is grabbed
signal on_grab_down(event: EventPointer)
## Emitted when a node is moved while grabbed
signal on_grab_move(event: EventPointer)
## Emitted when a node is released from being grabbed
signal on_grab_up(event: EventPointer)

## Emitted when a node is hovered
signal on_ray_enter(event: EventPointer)
## Emitted when a node is no longer hovered
signal on_ray_leave(event: EventPointer)

## Emitted when a key on the virtual keyboard is pressed
signal on_key_down(event: EventKey)
## Emitted when a key on the virtual keyboard is released
signal on_key_up(event: EventKey)

## Emitted when a button on the controller is pressed
signal on_action_down(event: EventAction)
## Emitted when a button on the controller is released
signal on_action_up(event: EventAction)
## Emitted when a value changes on the controller (e.g. joystick)
signal on_action_value(event: EventAction)

## Emitted when the node gains focus
signal on_focus_in(event: EventFocus)
## Emitted when the node loses focus
signal on_focus_out(event: EventFocus)

## Emitted when a finger enters a TouchArea
signal on_touch_enter(event: EventTouch)
## Emitted when a finger moves inside a TouchArea
signal on_touch_move(event: EventTouch)
## Emitted when a finger leaves a TouchArea
signal on_touch_leave(event: EventTouch)

## Emitted when a message is sent to the user
signal on_notify(event: EventNotify)

## Emitted when the slow tick event occurs
signal on_slow_tick(delta: float)

var _slow_tick: float = 0.0
func _physics_process(delta):
	_slow_tick += delta
	if _slow_tick >= SLOW_TICK:
		on_slow_tick.emit(_slow_tick)
		_slow_tick -= SLOW_TICK

var _active_node: Node = null

## Emits an event to the node tree
func emit(type: String, event: Event):
	if event is EventBubble:
		_bubble_call(type, event.target, event)
	else:
		_root_call(type, event)

## Shortcut for sending a notification
func notify(message: String, type:=EventNotify.Type.INFO):
	var event = EventNotify.new()
	event.message = message
	event.type = type
	emit("notify", event)

## Returns true when the node is focused
func is_focused(node: Node):
	return _active_node == node

func _handle_focus(target: Variant, event: EventBubble):
	if target != null:
		if target.is_in_group("ui_focus_skip"):
			return false
		if target.is_in_group("ui_focus_stop"):
			return true

	if is_instance_valid(_active_node) == false:
		_active_node = null

	var event_focus = EventFocus.new()
	event_focus.previous_target = _active_node
	event_focus.target = target
	event_focus.bubbling = false

	if _active_node != null&&_active_node.has_method(FN_PREFIX + "focus_out"):
		emit("focus_out", event_focus)
		_active_node.call(FN_PREFIX + "focus_out", event_focus)
		on_focus_out.emit(event_focus)

	if target == null||target.is_in_group("ui_focus") == false:
		_active_node = null
		return false

	_active_node = target

	if _active_node != null&&_active_node.has_method(FN_PREFIX + "focus_in"):
		_active_node.call(FN_PREFIX + "focus_in", event_focus)
		on_focus_in.emit(event_focus)

	return true

func _bubble_call(type: String, target: Variant, event: EventBubble, focused=false):
	if target == null:
		return false

	if target.has_method(FN_PREFIX + type):
		var updated_event = target.call(FN_PREFIX + type, event)

		if updated_event is EventBubble:
			updated_event.merge(event)
			event = updated_event

		if event.bubbling == false:
			return false

	if (type == "press_down"||type == "touch_enter")&&focused == false:
			focused = _handle_focus(target, event)

	for child in target.get_children():
		if child is Function&&child.has_method(FN_PREFIX + type):
			child.call(FN_PREFIX + type, event)

	var parent = target.get_parent()

	if parent != null&&parent is Node:
		_bubble_call(type, parent, event, focused)
	else:
		# in case the top has been reached
		_root_call(type, event)

	return true

func _root_call(type: String, event: Event):
	get(SIGNAL_PREFIX + type).emit(event)
