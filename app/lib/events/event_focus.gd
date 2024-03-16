extends Event
## Emitted when a Node with the `ui_focus` group is focused or unfocused.
class_name EventFocus

## The Node that is being focused or unfocused.
var target: Node
## The Node that was previously focused or unfocused.
var previous_target: Node