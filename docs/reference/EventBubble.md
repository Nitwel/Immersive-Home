# EventBubble
**Inherits:** [Event](/reference/Event.html)
    
## Description

Abstract Event to represent events that move "bubble" up the Node tree.

## Properties

| Name                       | Type                                                                | Default |
| -------------------------- | ------------------------------------------------------------------- | ------- |
| [bubbling](#prop-bubbling) | [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html) | `true`  |
| [target](#prop-target)     | [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html) |         |









## Property Descriptions

### bubbling: [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html) {#prop-bubbling}

If set to false, the event will stop bubbling up the Node tree.

### target: [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html) {#prop-target}

The Node that caused the event to start.
