# EventSystem
**Inherits:** [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html)
    


## Properties

| Name                               | Type                                                                  | Default |
| ---------------------------------- | --------------------------------------------------------------------- | ------- |
| [_active_node](#prop--active-node) | [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html)   | `null`  |
| [_slow_tick](#prop--slow-tick)     | [float](https://docs.godotengine.org/de/4.x/classes/class_float.html) | `0.0`   |

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

Emitted when a button on the controller is pressed

### on_action_up (event: [EventAction](/reference/EventAction.html)  ) {#on-action-up}

Emitted when a button on the controller is released

### on_action_value (event: [EventAction](/reference/EventAction.html)  ) {#on-action-value}

Emitted when a value changes on the controller (e.g. joystick)

### on_click (event: [EventPointer](/reference/EventPointer.html)  ) {#on-click}

Emitted when a node is clicked

### on_focus_in (event: [EventFocus](/reference/EventFocus.html)  ) {#on-focus-in}

Emitted when the node gains focus

### on_focus_out (event: [EventFocus](/reference/EventFocus.html)  ) {#on-focus-out}

Emitted when the node loses focus

### on_grab_down (event: [EventPointer](/reference/EventPointer.html)  ) {#on-grab-down}

Emitted when a node is grabbed

### on_grab_move (event: [EventPointer](/reference/EventPointer.html)  ) {#on-grab-move}

Emitted when a node is moved while grabbed

### on_grab_up (event: [EventPointer](/reference/EventPointer.html)  ) {#on-grab-up}

Emitted when a node is released from being grabbed

### on_key_down (event: [EventKey](/reference/EventKey.html)  ) {#on-key-down}

Emitted when a key on the virtual keyboard is pressed

### on_key_up (event: [EventKey](/reference/EventKey.html)  ) {#on-key-up}

Emitted when a key on the virtual keyboard is released

### on_notify (event: [EventNotify](/reference/EventNotify.html)  ) {#on-notify}

Emitted when a message is sent to the user

### on_press_down (event: [EventPointer](/reference/EventPointer.html)  ) {#on-press-down}

Emitted when a node is pressed down

### on_press_move (event: [EventPointer](/reference/EventPointer.html)  ) {#on-press-move}

Emitted when a node is moved while pressed

### on_press_up (event: [EventPointer](/reference/EventPointer.html)  ) {#on-press-up}

Emitted when a node is released

### on_ray_enter (event: [EventPointer](/reference/EventPointer.html)  ) {#on-ray-enter}

Emitted when a node is hovered

### on_ray_leave (event: [EventPointer](/reference/EventPointer.html)  ) {#on-ray-leave}

Emitted when a node is no longer hovered

### on_slow_tick (delta: [float](https://docs.godotengine.org/de/4.x/classes/class_float.html)  ) {#on-slow-tick}

Emitted when the slow tick event occurs

### on_touch_enter (event: [EventTouch](/reference/EventTouch.html)  ) {#on-touch-enter}

Emitted when a finger enters a TouchArea

### on_touch_leave (event: [EventTouch](/reference/EventTouch.html)  ) {#on-touch-leave}

Emitted when a finger leaves a TouchArea

### on_touch_move (event: [EventTouch](/reference/EventTouch.html)  ) {#on-touch-move}

Emitted when a finger moves inside a TouchArea



## Constants

### FN_PREFIX = `"_on_"` {#const-FN-PREFIX}

Prefix for the function names to be called

### SIGNAL_PREFIX = `"on_"` {#const-SIGNAL-PREFIX}

Prefix for the signal names to be emitted

### SLOW_TICK = `0.1` {#const-SLOW-TICK}

Tick rate for the slow tick event

## Property Descriptions

### _active_node: [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html) {#prop--active-node}

No description provided yet.

### _slow_tick: [float](https://docs.godotengine.org/de/4.x/classes/class_float.html) {#prop--slow-tick}

No description provided yet.

## Method Descriptions

###  _bubble_call (type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , target: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) , event: [EventBubble](/reference/EventBubble.html) , focused: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#-bubble-call}

No description provided yet.

###  _handle_focus (target: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) , event: [EventBubble](/reference/EventBubble.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#-handle-focus}

No description provided yet.

###  _physics_process (delta: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html)  ) -> void {#-physics-process}

No description provided yet.

###  _root_call (type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , event: [Event](/reference/Event.html)  ) -> void {#-root-call}

No description provided yet.

###  emit (type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , event: [Event](/reference/Event.html)  ) -> void {#emit}

Emits an event to the node tree

###  is_focused (node: [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#is-focused}

Returns true when the node is focused

###  notify (message: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , type: [int](https://docs.godotengine.org/de/4.x/classes/class_int.html)  ) -> void {#notify}

Shortcut for sending a notification
