# Pointer
**Inherits:** [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html)
    


## Properties

| Name                              | Type                                                                          | Default            |
| --------------------------------- | ----------------------------------------------------------------------------- | ------------------ |
| [click_point](#click-point)       | [Vector3](https://docs.godotengine.org/de/4.x/classes/class_vector3.html)     | `Vector3(0, 0, 0)` |
| [initiator](#initiator)           | [Initiator](/reference/lib--utils--pointer--initiator.html)                   |                    |
| [is_grabbed](#is-grabbed)         | [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html)           | `false`            |
| [is_pressed](#is-pressed)         | [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html)           | `false`            |
| [last_collided](#last-collided)   | [Object](https://docs.godotengine.org/de/4.x/classes/class_object.html)       | `null`             |
| [moved](#moved)                   | [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html)           | `false`            |
| [ray](#ray)                       | [RayCast3D](https://docs.godotengine.org/de/4.x/classes/class_raycast3d.html) |                    |
| [time_pressed](#time-pressed)     | [float](https://docs.godotengine.org/de/4.x/classes/class_float.html)         | `0.0`              |
| [timespan_click](#timespan-click) | [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html)     | `400.0`            |

## Methods

| Returns | Name                                                                                                                                                                                             |
| ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| void    | [_emit_event](#-emit-event) ( type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), target: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) ) |
| void    | [_handle_enter_leave](#-handle-enter-leave) (  )                                                                                                                                                 |
| void    | [_handle_move](#-handle-move) (  )                                                                                                                                                               |
| void    | [_init](#-init) ( initiator: [Initiator](/reference/lib--utils--pointer--initiator.html), ray: [RayCast3D](https://docs.godotengine.org/de/4.x/classes/class_raycast3d.html) )                   |
| void    | [_on_pressed](#-on-pressed) ( type: [int](https://docs.godotengine.org/de/4.x/classes/class_int.html) )                                                                                          |
| void    | [_on_released](#-on-released) ( type: [int](https://docs.godotengine.org/de/4.x/classes/class_int.html) )                                                                                        |
| void    | [_physics_process](#-physics-process) ( _delta: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) )                                                                      |
| void    | [_ready](#-ready) (  )                                                                                                                                                                           |



## Constants


### Initiator = `<Object>` {#const-Initiator}

No description provided yet.
                

## Property Descriptions

### click_point: [Vector3](https://docs.godotengine.org/de/4.x/classes/class_vector3.html) {#click-point}

No description provided yet.

### initiator: [Initiator](/reference/lib--utils--pointer--initiator.html) {#initiator}

No description provided yet.

### is_grabbed: [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html) {#is-grabbed}

No description provided yet.

### is_pressed: [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html) {#is-pressed}

No description provided yet.

### last_collided: [Object](https://docs.godotengine.org/de/4.x/classes/class_object.html) {#last-collided}

No description provided yet.

### moved: [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html) {#moved}

No description provided yet.

### ray: [RayCast3D](https://docs.godotengine.org/de/4.x/classes/class_raycast3d.html) {#ray}

No description provided yet.

### time_pressed: [float](https://docs.godotengine.org/de/4.x/classes/class_float.html) {#time-pressed}

No description provided yet.

### timespan_click: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#timespan-click}

No description provided yet.

## Method Descriptions

### _emit_event (type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , target: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html)  ) -> void {#-emit-event}

No description provided yet.

### _handle_enter_leave ( ) -> void {#-handle-enter-leave}

No description provided yet.

### _handle_move ( ) -> void {#-handle-move}

No description provided yet.

### _init (initiator: [Initiator](/reference/lib--utils--pointer--initiator.html) , ray: [RayCast3D](https://docs.godotengine.org/de/4.x/classes/class_raycast3d.html)  ) -> void {#-init}

No description provided yet.

### _on_pressed (type: [int](https://docs.godotengine.org/de/4.x/classes/class_int.html)  ) -> void {#-on-pressed}

No description provided yet.

### _on_released (type: [int](https://docs.godotengine.org/de/4.x/classes/class_int.html)  ) -> void {#-on-released}

No description provided yet.

### _physics_process (_delta: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html)  ) -> void {#-physics-process}

No description provided yet.

### _ready ( ) -> void {#-ready}

No description provided yet.
