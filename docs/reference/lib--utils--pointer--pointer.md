# Pointer
**Inherits:** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

## Description

Logic for the raycast to interact with objects

## Properties

| Name                                   | Type                                                                             | Default            |
| -------------------------------------- | -------------------------------------------------------------------------------- | ------------------ |
| [click_point](#prop-click-point)       | [Vector3](https://docs.godotengine.org/en/stable/classes/class_vector3.html)     | `Vector3(0, 0, 0)` |
| [grab_target](#prop-grab-target)       | [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)       | `null`             |
| [initiator](#prop-initiator)           | [Initiator](/reference/lib--utils--pointer--initiator.html)                      |                    |
| [is_grabbed](#prop-is-grabbed)         | [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)           | `false`            |
| [is_pressed](#prop-is-pressed)         | [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)           | `false`            |
| [last_collided](#prop-last-collided)   | [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)       | `null`             |
| [moved](#prop-moved)                   | [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)           | `false`            |
| [press_target](#prop-press-target)     | [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)       | `null`             |
| [ray](#prop-ray)                       | [RayCast3D](https://docs.godotengine.org/en/stable/classes/class_raycast3d.html) |                    |
| [time_pressed](#prop-time-pressed)     | [float](https://docs.godotengine.org/en/stable/classes/class_float.html)         | `0.0`              |
| [timespan_click](#prop-timespan-click) | [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)     | `400.0`            |

## Methods

| Returns                                                                      | Name                                                                                                                                                                                                   |
| ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) | [_emit_event](#-emit-event) ( type: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), target: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) ) |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) | [_handle_enter_leave](#-handle-enter-leave) (  )                                                                                                                                                       |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) | [_handle_move](#-handle-move) (  )                                                                                                                                                                     |
| void                                                                         | [_init](#-init) ( initiator: [Initiator](/reference/lib--utils--pointer--initiator.html), ray: [RayCast3D](https://docs.godotengine.org/en/stable/classes/class_raycast3d.html) )                      |
| void                                                                         | [_physics_process](#-physics-process) ( _delta: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) )                                                                         |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) | [_reset_hover](#-reset-hover) (  )                                                                                                                                                                     |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) | [pressed](#pressed) ( type: [Initiator.EventType](/reference/lib--utils--pointer--initiator.html#enum-EventType) )                                                                                     |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) | [release_all](#release-all) (  )                                                                                                                                                                       |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) | [released](#released) ( type: [Initiator.EventType](/reference/lib--utils--pointer--initiator.html#enum-EventType) )                                                                                   |

## Constants

### Initiator = `<Object>` {#const-Initiator}

No description provided yet.

## Property Descriptions

### click_point: [Vector3](https://docs.godotengine.org/en/stable/classes/class_vector3.html) {#prop-click-point}

No description provided yet.

### grab_target: [Object](https://docs.godotengine.org/en/stable/classes/class_object.html) {#prop-grab-target}

No description provided yet.

### initiator: [Initiator](/reference/lib--utils--pointer--initiator.html) {#prop-initiator}

No description provided yet.

### is_grabbed: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#prop-is-grabbed}

No description provided yet.

### is_pressed: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#prop-is-pressed}

Trigger and grip are tracked separately so that holding both at the same time (e.g. a hand pinching with index and middle finger) can't end one of them on the wrong target or swallow its release event.

### last_collided: [Object](https://docs.godotengine.org/en/stable/classes/class_object.html) {#prop-last-collided}

Node currently hovered by the ray

### moved: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#prop-moved}

No description provided yet.

### press_target: [Object](https://docs.godotengine.org/en/stable/classes/class_object.html) {#prop-press-target}

No description provided yet.

### ray: [RayCast3D](https://docs.godotengine.org/en/stable/classes/class_raycast3d.html) {#prop-ray}

No description provided yet.

### time_pressed: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) {#prop-time-pressed}

No description provided yet.

### timespan_click: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#prop-timespan-click}

No description provided yet.

## Method Descriptions

### _emit_event (type: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , target: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-emit-event}

No description provided yet.

### _handle_enter_leave ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-handle-enter-leave}

No description provided yet.

### _handle_move ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-handle-move}

No description provided yet.

### _init (initiator: [Initiator](/reference/lib--utils--pointer--initiator.html) , ray: [RayCast3D](https://docs.godotengine.org/en/stable/classes/class_raycast3d.html)  ) -> void {#-init}

No description provided yet.

### _physics_process (_delta: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)  ) -> void {#-physics-process}

No description provided yet.

### _reset_hover ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-reset-hover}

No description provided yet.

### pressed (type: [Initiator.EventType](/reference/lib--utils--pointer--initiator.html#enum-EventType)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#pressed}

No description provided yet.

### release_all ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#release-all}

Releases trigger and grip, e.g. when the hand/controller stops being tracked.

### released (type: [Initiator.EventType](/reference/lib--utils--pointer--initiator.html#enum-EventType)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#released}

No description provided yet.
