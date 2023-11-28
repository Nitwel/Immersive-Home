extends EventBubble
class_name EventPointer

const Initiator = preload("res://lib/utils/pointer/initiator.gd")

var initiator: Initiator
var ray: RayCast3D