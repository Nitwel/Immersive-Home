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

var active_node: Node = null

func emit(type: String, event: Event):
	if event is EventBubble:
		_bubble_call(type, event.target, event)
		if event.target.is_in_group("ui_focus"):
			_handle_focus(event.target)
		else:
			_handle_focus(null)
	else:
		_root_call(type, event)

func _handle_focus(node: Node):
	var event = EventFocus.new()
	event.previous_target = active_node
	event.target = node

	if active_node != null && active_node.has_method(FN_PREFIX + "focus_in"):
		active_node.call(FN_PREFIX + "focus_out", event)
		on_focus_out.emit(event)

	active_node = node

	if active_node != null:
		active_node.call(FN_PREFIX + "focus_in", event)
		on_focus_in.emit(event)

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
