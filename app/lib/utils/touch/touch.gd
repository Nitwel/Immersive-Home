extends Node
## Handles touch events and emits them to the EventSystem

const Finger = preload ("res://lib/utils/touch/finger.gd")

## Record<Finger.Type, Area3D>
var finger_areas: Dictionary

var areas_entered = {}

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

func _physics_process(_delta):
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
		fingers.append(finger)

	event.fingers = fingers

	EventSystem.emit(type, event)
