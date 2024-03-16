# EventSystem
**Inherits:** [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html)
    


## Properties

| Name                          | Type                                                                  | Default |
| ----------------------------- | --------------------------------------------------------------------- | ------- |
| [_active_node](#-active-node) | [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html)   | `null`  |
| [_slow_tick](#-slow-tick)     | [float](https://docs.godotengine.org/de/4.x/classes/class_float.html) | `0.0`   |

## Methods

| Returns                                                                   | Name                                                                                                                                                                                                                                                                                                                                      |
| ------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [_bubble_call](#-bubble-call) ( type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), target: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html), event: [EventBubble](/reference/EventBubble.html), focused: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) ) |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [_handle_focus](#-handle-focus) ( target: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html), event: [EventBubble](/reference/EventBubble.html) )                                                                                                                                                                  |
| void                                                                      | [_physics_process](#-physics-process) ( delta: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) )                                                                                                                                                                                                                |
| void                                                                      | [_root_call](#-root-call) ( type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), event: [Event](/reference/Event.html) )                                                                                                                                                                                        |
| void                                                                      | [emit](#emit) ( type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), event: [Event](/reference/Event.html) )                                                                                                                                                                                                    |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [is_focused](#is-focused) ( node: [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html) )                                                                                                                                                                                                                                   |
| void                                                                      | [notify](#notify) ( message: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), type: [int](https://docs.godotengine.org/de/4.x/classes/class_int.html) )                                                                                                                                                           |

## Signals

### on_action_down (event: [EventAction](/reference/EventAction.html)  ) {#on-action-down}

No description provided yet.

### on_action_up (event: [EventAction](/reference/EventAction.html)  ) {#on-action-up}

No description provided yet.

### on_action_value (event: [EventAction](/reference/EventAction.html)  ) {#on-action-value}

No description provided yet.

### on_click (event: [EventPointer](/reference/EventPointer.html)  ) {#on-click}

No description provided yet.

### on_focus_in (event: [EventFocus](/reference/EventFocus.html)  ) {#on-focus-in}

No description provided yet.

### on_focus_out (event: [EventFocus](/reference/EventFocus.html)  ) {#on-focus-out}

No description provided yet.

### on_grab_down (event: [EventPointer](/reference/EventPointer.html)  ) {#on-grab-down}

No description provided yet.

### on_grab_move (event: [EventPointer](/reference/EventPointer.html)  ) {#on-grab-move}

No description provided yet.

### on_grab_up (event: [EventPointer](/reference/EventPointer.html)  ) {#on-grab-up}

No description provided yet.

### on_key_down (event: [EventKey](/reference/EventKey.html)  ) {#on-key-down}

No description provided yet.

### on_key_up (event: [EventKey](/reference/EventKey.html)  ) {#on-key-up}

No description provided yet.

### on_notify (event: [EventNotify](/reference/EventNotify.html)  ) {#on-notify}

No description provided yet.

### on_press_down (event: [EventPointer](/reference/EventPointer.html)  ) {#on-press-down}

No description provided yet.

### on_press_move (event: [EventPointer](/reference/EventPointer.html)  ) {#on-press-move}

No description provided yet.

### on_press_up (event: [EventPointer](/reference/EventPointer.html)  ) {#on-press-up}

No description provided yet.

### on_ray_enter (event: [EventPointer](/reference/EventPointer.html)  ) {#on-ray-enter}

No description provided yet.

### on_ray_leave (event: [EventPointer](/reference/EventPointer.html)  ) {#on-ray-leave}

No description provided yet.

### on_slow_tick (delta: [float](https://docs.godotengine.org/de/4.x/classes/class_float.html)  ) {#on-slow-tick}

No description provided yet.

### on_touch_enter (event: [EventTouch](/reference/EventTouch.html)  ) {#on-touch-enter}

No description provided yet.

### on_touch_leave (event: [EventTouch](/reference/EventTouch.html)  ) {#on-touch-leave}

No description provided yet.

### on_touch_move (event: [EventTouch](/reference/EventTouch.html)  ) {#on-touch-move}

No description provided yet.

## Constants


### FN_PREFIX = `"_on_"` {#const-FN-PREFIX}

No description provided yet.
                


### SIGNAL_PREFIX = `"on_"` {#const-SIGNAL-PREFIX}

No description provided yet.
                


### SLOW_TICK = `0.1` {#const-SLOW-TICK}

No description provided yet.
                

## Property Descriptions

### _active_node: [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html) {#-active-node}

No description provided yet.

### _slow_tick: [float](https://docs.godotengine.org/de/4.x/classes/class_float.html) {#-slow-tick}

No description provided yet.

## Method Descriptions

### _bubble_call (type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , target: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) , event: [EventBubble](/reference/EventBubble.html) , focused: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#-bubble-call}

No description provided yet.

### _handle_focus (target: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) , event: [EventBubble](/reference/EventBubble.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#-handle-focus}

No description provided yet.

### _physics_process (delta: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html)  ) -> void {#-physics-process}

No description provided yet.

### _root_call (type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , event: [Event](/reference/Event.html)  ) -> void {#-root-call}

No description provided yet.

### emit (type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , event: [Event](/reference/Event.html)  ) -> void {#emit}

No description provided yet.

### is_focused (node: [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#is-focused}

No description provided yet.

### notify (message: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , type: [int](https://docs.godotengine.org/de/4.x/classes/class_int.html)  ) -> void {#notify}

No description provided yet.
