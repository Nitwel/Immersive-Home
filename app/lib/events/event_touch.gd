extends EventBubble
## Emitted when a finger enters or leaves a FingerArea.
class_name EventTouch

const Finger = preload ("res://lib/utils/touch/finger.gd")

## The list of fingers that are currently in the area.
var fingers: Array[Finger] = []

## Checks if a specific finger is currently in the area.
func has_finger(finger: Finger.Type):
	for f in fingers:
		if f.type == finger:
			return true
	return false