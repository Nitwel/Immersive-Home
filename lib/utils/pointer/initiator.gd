extends RefCounted

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

signal on_press(type: EventType)
signal on_release(type: EventType)

var node: Node3D
var type: Type

func is_right() -> bool:
	return type == Type.CONTROLLER_RIGHT || type == Type.HAND_RIGHT