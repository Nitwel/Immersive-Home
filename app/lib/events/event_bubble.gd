extends Event
## Abstract Event to represent events that move "bubble" up the Node tree.
class_name EventBubble

## If set to false, the event will stop bubbling up the Node tree.
var bubbling := true
## The Node that caused the event to start.
var target: Node