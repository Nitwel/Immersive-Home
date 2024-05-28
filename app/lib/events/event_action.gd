extends Event
## EventAction is emitted when the user presses a button or trigger on the controller.
class_name EventAction

const Initiator = preload ("res://lib/utils/pointer/initiator.gd")

## The name of the action that was triggered.
var name: String
## Boolean, Float or Vector2
var value
## The initiator that started the event.
var initiator: Initiator