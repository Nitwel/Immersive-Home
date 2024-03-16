# EventSystem
    


## Properties

| Name                          | Type                                                                  | Default |
| ----------------------------- | --------------------------------------------------------------------- | ------- |
| [_active_node](#-active-node) | [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html)   | `null`  |
| [_slow_tick](#-slow-tick)     | [float](https://docs.godotengine.org/de/4.x/classes/class_float.html) | `0.0`   |

## Methods

| Returns                                                                   | Name                                                                                                                                                                                                                                                                                                                                                                             |
| ------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [_bubble_call](#-bubble-call) ( type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), target: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html), event: [EventBubble](https://docs.godotengine.org/de/4.x/classes/class_eventbubble.html), focused: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) ) |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [_handle_focus](#-handle-focus) ( target: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html), event: [EventBubble](https://docs.godotengine.org/de/4.x/classes/class_eventbubble.html) )                                                                                                                                                                  |
| void                                                                      | [_physics_process](#-physics-process) ( delta: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) )                                                                                                                                                                                                                                                       |
| void                                                                      | [_root_call](#-root-call) ( type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), event: [Event](https://docs.godotengine.org/de/4.x/classes/class_event.html) )                                                                                                                                                                                        |
| void                                                                      | [emit](#emit) ( type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), event: [Event](https://docs.godotengine.org/de/4.x/classes/class_event.html) )                                                                                                                                                                                                    |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [is_focused](#is-focused) ( node: [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html) )                                                                                                                                                                                                                                                                          |
| void                                                                      | [notify](#notify) ( message: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), type: [int](https://docs.godotengine.org/de/4.x/classes/class_int.html) )                                                                                                                                                                                                  |

## Property Descriptions

### _active_node: [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html) {#-active-node}

No description provided yet.

### _slow_tick: [float](https://docs.godotengine.org/de/4.x/classes/class_float.html) {#-slow-tick}

No description provided yet.

## Method Descriptions

### _bubble_call ( type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), target: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html), event: [EventBubble](https://docs.godotengine.org/de/4.x/classes/class_eventbubble.html), focused: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#-bubble-call}

No description provided yet.

### _handle_focus ( target: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html), event: [EventBubble](https://docs.godotengine.org/de/4.x/classes/class_eventbubble.html) ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#-handle-focus}

No description provided yet.

### _physics_process ( delta: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) ) -> void {#-physics-process}

No description provided yet.

### _root_call ( type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), event: [Event](https://docs.godotengine.org/de/4.x/classes/class_event.html) ) -> void {#-root-call}

No description provided yet.

### emit ( type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), event: [Event](https://docs.godotengine.org/de/4.x/classes/class_event.html) ) -> void {#emit}

No description provided yet.

### is_focused ( node: [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html) ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#is-focused}

No description provided yet.

### notify ( message: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), type: [int](https://docs.godotengine.org/de/4.x/classes/class_int.html) ) -> void {#notify}

No description provided yet.
