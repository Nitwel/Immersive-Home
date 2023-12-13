extends Node

const FN_PREFIX = "_on_"
const SIGNAL_PREFIX = "on_"

# Interaction Events
signal on_click(event: EventPointer)
signal on_press_down(event: EventPointer)
signal on_press_move(event: EventPointer)
signal on_press_up(event: EventPointer)
signal on_grab_down(event: EventPointer)
signal on_grab_move(event: EventPointer)
signal on_grab_up(event: EventPointer)
signal on_ray_enter(event: EventPointer)
signal on_ray_leave(event: EventPointer)

signal on_key_down(event: EventKey)
signal on_key_up(event: EventKey)

signal on_focus_in(event: EventFocus)
signal on_focus_out(event: EventFocus)

signal on_touch_enter(event: EventTouch)
signal on_touch_move(event: EventTouch)
signal on_touch_leave(event: EventTouch)

signal on_notify(event: EventNotify)

var _active_node: Node = null

func emit(type: String, event: Event):
	if event is EventBubble:
		_bubble_call(type, event.target, event)
	else:
		_root_call(type, event)

func notify(message: String, type := EventNotify.Type.INFO):
	var event = EventNotify.new()
	event.message = message
	event.type = type
	emit("notify", event)

func is_focused(node: Node):
	return _active_node == node

func _handle_focus(target: Variant, event: EventBubble):
	if target != null:
		if target.is_in_group("ui_focus_skip"):
			return false
		if target.is_in_group("ui_focus_stop"):
			return true

	var event_focus = EventFocus.new()
	event_focus.previous_target = _active_node
	event_focus.target = target

	if _active_node != null && _active_node.has_method(FN_PREFIX + "focus_out"):
		_active_node.call(FN_PREFIX + "focus_out", event_focus)
		on_focus_out.emit(event_focus)

	if target == null || target.is_in_group("ui_focus") == false:
		_active_node = null
		return false

	_active_node = target

	if _active_node != null && _active_node.has_method(FN_PREFIX + "focus_in"):
		_active_node.call(FN_PREFIX + "focus_in", event_focus)
		on_focus_in.emit(event_focus)

	return true

func _bubble_call(type: String, target: Variant, event: EventBubble, focused = false):
	if target == null:
		return false

	if target.has_method(FN_PREFIX + type):
		var updated_event = target.call(FN_PREFIX + type, event)

		if updated_event is EventBubble:
			updated_event.merge(event)
			event = updated_event

		if event.bubbling == false:
			return false

	if (type == "press_down" || type == "touch_enter") && focused == false:
			focused = _handle_focus(target, event)

	for child in target.get_children():
		if child is Function && child.has_method(FN_PREFIX + type):
			child.call(FN_PREFIX + type, event)

	var parent = target.get_parent()

	if parent != null && parent is Node:
		_bubble_call(type, parent, event, focused)
	else:
		# in case the top has been reached
		_root_call(type, event)

	return true


func _root_call(type: String, event: Event):
	get(SIGNAL_PREFIX + type).emit(event)
