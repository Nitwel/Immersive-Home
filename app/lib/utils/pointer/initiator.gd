extends RefCounted
## Defines what triggered a EventPointer

enum Type {
	CONTROLLER_LEFT,
	CONTROLLER_RIGHT,
	HAND_LEFT,
	HAND_RIGHT,
}

enum EventType {
	GRIP,
	TRIGGER,
}

var node: Node3D
var type: Type

func is_right() -> bool:
	return type == Type.CONTROLLER_RIGHT||type == Type.HAND_RIGHT