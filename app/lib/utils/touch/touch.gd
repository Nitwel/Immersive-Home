extends Node
## Handles touch events and emits them to the EventSystem

const Finger = preload("res://lib/utils/touch/finger.gd")

## Record<Finger.Type, Area3D>
var finger_areas: Dictionary

var areas_entered = {}

## Record<Finger.Type, [previous: Vector3, current: Vector3]>, sampled every physics tick.
var _positions = {}

## Returns true if any finger touches an area.
## When finger_type is given, only that finger is checked.
func is_touching(finger_type: int = -1) -> bool:
	if finger_type == -1:
		return areas_entered.keys().size() > 0

	for fingers in areas_entered.values():
		if fingers.has(finger_type):
			return true

	return false

func add_finger(finger_type: Finger.Type, area: Area3D):
	finger_areas[finger_type] = area

	area.area_entered.connect(func(entered_area):
		_on_area_entered(finger_type, entered_area)
	)

	area.area_exited.connect(func(entered_area):
		_on_area_exited(finger_type, entered_area)
	)

func remove_finger(finger_type: Finger.Type):
	if finger_areas.has(finger_type):
		finger_areas.erase(finger_type)
	_positions.erase(finger_type)

func _record_positions():
	for finger_type in finger_areas:
		var area: Area3D = finger_areas[finger_type]
		if not is_instance_valid(area) or not area.is_inside_tree():
			continue

		var position = area.global_position
		var entry = _positions.get(finger_type)

		if entry == null:
			_positions[finger_type] = [position, position]
		elif not entry[1].is_equal_approx(position):
			_positions[finger_type] = [entry[1], position]

func _previous_position(finger_type: Finger.Type) -> Vector3:
	var area: Area3D = finger_areas[finger_type]
	var entry = _positions.get(finger_type)

	if entry == null:
		return area.global_position
	if entry[1].is_equal_approx(area.global_position):
		return entry[0]
	return entry[1]

func _physics_process(_delta):
	_record_positions()

	for area in areas_entered.keys():
		if areas_entered.has(area) == false:
			return
		_emit_event("touch_move", area)

func _on_area_entered(finger_type, area):
	if areas_entered.has(area):
		if !areas_entered[area].has(finger_type):
			areas_entered[area].append(finger_type)
			_emit_event("touch_enter", area)
	else:
		areas_entered[area] = [finger_type]
		_emit_event("touch_enter", area)

func _on_area_exited(finger_type, area):
	if areas_entered.has(area):
		if areas_entered[area].has(finger_type):
			areas_entered[area].erase(finger_type)

		if areas_entered[area].size() == 0:
			_emit_event("touch_leave", area)
			areas_entered.erase(area)

func _emit_event(type: String, target):
	var event = EventTouch.new()
	event.target = target
	var fingers: Array[Finger] = []
	for finger_type in areas_entered[target]:
		var finger = Finger.new()
		finger.type = finger_type
		finger.area = finger_areas[finger_type]
		finger.previous_position = _previous_position(finger_type)
		fingers.append(finger)

	event.fingers = fingers

	EventSystem.emit(type, event)
