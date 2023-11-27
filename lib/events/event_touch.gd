extends EventBubble
class_name EventTouch

const Finger = preload("res://lib/utils/touch/finger.gd")

var fingers: Array[Finger] = []

func has_finger(finger: Finger.Type):
	for f in fingers:
		if f.type == finger:
			return true
	return false