extends Event
## EventAction is emitted when the user presses a button or trigger on the controller.
class_name EventAction

## The name of the action that was triggered.
var name: String
## True if the right controller triggered the action, false if the left controller triggered the action.
var right_controller: bool
## Boolean, Float or Vector2
var value