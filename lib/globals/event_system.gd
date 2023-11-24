extends Node

const FN_PREFIX = "_on_"
const SIGNAL_PREFIX = "on_"

# Interaction Events
signal on_click(event: EventRay)
signal on_press_down(event: EventRay)
signal on_press_move(event: EventRay)
signal on_press_up(event: EventRay)
signal on_grab_down(event: EventRay)
signal on_grab_move(event: EventRay)
signal on_grab_up(event: EventRay)
signal on_ray_enter(event: EventRay)
signal on_ray_leave(event: EventRay)

signal on_key_down(event: EventKey)
signal on_key_up(event: EventKey)

signal on_focus_in(event: EventFocus)
signal on_focus_out(event: EventFocus)

var _active_node: Node = null

func emit(type: String, event: Event):
	if event is EventBubble:
		_bubble_call(type, event.target, event)
		if type == "press_down":
			_handle_focus(event)
	else:
		_root_call(type, event)

func is_focused(node: Node):
	return _active_node == node

func _handle_focus(event: EventRay):
	if event.target != null && event.target.is_in_group("ui_focus_skip"):
		return

	var event_focus = EventFocus.new()
	event_focus.previous_target = _active_node
	event_focus.target = event.target
	event_focus.ray = event.ray

	if _active_node != null && _active_node.has_method(FN_PREFIX + "focus_out"):
		_active_node.call(FN_PREFIX + "focus_out", event_focus)
		on_focus_out.emit(event_focus)

	if event.target == null || event.target.is_in_group("ui_focus") == false:
		_active_node = null
		return

	_active_node = event.target

	if _active_node != null && _active_node.has_method(FN_PREFIX + "focus_in"):
		_active_node.call(FN_PREFIX + "focus_in", event_focus)
		on_focus_in.emit(event_focus)

func _bubble_call(type: String, target: Variant, event: EventBubble):
	if target == null:
		return false

	if target.has_method(FN_PREFIX + type):
		var updated_event = target.call(FN_PREFIX + type, event)

		if updated_event is EventBubble:
			updated_event.merge(event)
			event = updated_event

		if event.bubbling == false:
			return false

	for child in target.get_children():
		if child is Function && child.has_method(FN_PREFIX + type):
			child.call(FN_PREFIX + type, event)

	var parent = target.get_parent()

	if parent != null && parent is Node:
		_bubble_call(type, parent, event)
	else:
		# in case the top has been reached
		_root_call(type, event)

	return true


func _root_call(type: String, event: Event):
	get(SIGNAL_PREFIX + type).emit(event)
