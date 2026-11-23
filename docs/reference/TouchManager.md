# TouchManager
**Inherits:** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

## Description

Handles touch events and emits them to the EventSystem

## Properties

| Name                                 | Type                                                                               | Default |
| ------------------------------------ | ---------------------------------------------------------------------------------- | ------- |
| [_positions](#prop--positions)       | [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | `{}`    |
| [areas_entered](#prop-areas-entered) | [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | `{}`    |
| [finger_areas](#prop-finger-areas)   | [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) |         |

## Methods

| Returns                                                                      | Name                                                                                                                                                                                                                    |
| ---------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) | [_emit_event](#-emit-event) ( type: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), target: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) )                  |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) | [_on_area_entered](#-on-area-entered) ( finger_type: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), area: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) ) |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) | [_on_area_exited](#-on-area-exited) ( finger_type: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), area: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) )   |
| void                                                                         | [_physics_process](#-physics-process) ( _delta: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) )                                                                                          |
| [Vector3](https://docs.godotengine.org/en/stable/classes/class_vector3.html) | [_previous_position](#-previous-position) ( finger_type: [Finger.Type](/reference/lib--utils--touch--finger.html#enum-Type) )                                                                                           |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) | [_record_positions](#-record-positions) (  )                                                                                                                                                                            |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) | [add_finger](#add-finger) ( finger_type: [Finger.Type](/reference/lib--utils--touch--finger.html#enum-Type), area: [Area3D](https://docs.godotengine.org/en/stable/classes/class_area3d.html) )                         |
| [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)       | [is_touching](#is-touching) ( finger_type: [int](https://docs.godotengine.org/en/stable/classes/class_int.html) = `-1` )                                                                                                |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) | [remove_finger](#remove-finger) ( finger_type: [Finger.Type](/reference/lib--utils--touch--finger.html#enum-Type) )                                                                                                     |

## Constants

### Finger = `<Object>` {#const-Finger}

No description provided yet.

## Property Descriptions

### _positions: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#prop--positions}

Record&lt;Finger.Type, [previous: Vector3, current: Vector3]>, sampled every physics tick.

### areas_entered: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#prop-areas-entered}

No description provided yet.

### finger_areas: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#prop-finger-areas}

Record&lt;Finger.Type, Area3D>

## Method Descriptions

### _emit_event (type: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , target: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-emit-event}

No description provided yet.

### _on_area_entered (finger_type: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , area: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-on-area-entered}

No description provided yet.

### _on_area_exited (finger_type: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , area: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-on-area-exited}

No description provided yet.

### _physics_process (_delta: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)  ) -> void {#-physics-process}

No description provided yet.

### _previous_position (finger_type: [Finger.Type](/reference/lib--utils--touch--finger.html#enum-Type)  ) -> [Vector3](https://docs.godotengine.org/en/stable/classes/class_vector3.html) {#-previous-position}

No description provided yet.

### _record_positions ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-record-positions}

No description provided yet.

### add_finger (finger_type: [Finger.Type](/reference/lib--utils--touch--finger.html#enum-Type) , area: [Area3D](https://docs.godotengine.org/en/stable/classes/class_area3d.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#add-finger}

No description provided yet.

### is_touching (finger_type: [int](https://docs.godotengine.org/en/stable/classes/class_int.html) = `-1`  ) -> [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#is-touching}

Returns true if any finger touches an area. When finger_type is given, only that finger is checked.

### remove_finger (finger_type: [Finger.Type](/reference/lib--utils--touch--finger.html#enum-Type)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#remove-finger}

No description provided yet.
