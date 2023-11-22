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

func emit(type: String, event: Event):
	if event is EventBubble:
		_bubble_call(type, event.target, event)
	else:
		_root_call(type, event)


func _bubble_call(type: String, target: Variant, event: EventBubble):
	if target == null:
		return

	if target.has_method(FN_PREFIX + type):
		var updated_event = target.call(FN_PREFIX + type, event)

		if updated_event is EventBubble:
			updated_event.merge(event)
			event = updated_event

		if event.bubbling == false:
			return

	for child in target.get_children():
		if child is Function && child.has_method(FN_PREFIX + type):
			child.call(FN_PREFIX + type, event)

	var parent = target.get_parent()

	if parent != null && parent is Node:
		_bubble_call(type, parent, event)
	else:
		# in case the top has been reached
		_root_call(type, event)


func _root_call(type: String, event: Event):
	get(SIGNAL_PREFIX + type).emit(event)
