extends EventBubble
## Triggered when the raycast of the controller or hand hits or clicks on an object.
class_name EventPointer

const Initiator = preload ("res://lib/utils/pointer/initiator.gd")

## Either the controller or the hand that triggered the event.
var initiator: Initiator
## The raycast that collided with the target.
var ray: RayCast3D