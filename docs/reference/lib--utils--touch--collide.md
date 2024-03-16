# Collide
**Inherits:** [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html)
    
## Description

Calculates collision for fingers and FingerAreas

## Properties

| Name                                   | Type                                                                            | Default |
| -------------------------------------- | ------------------------------------------------------------------------------- | ------- |
| [bodies_entered](#prop-bodies-entered) | [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html)       |         |
| [finger_areas](#prop-finger-areas)     | [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html) |         |
| [hand_left](#prop-hand-left)           | [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html)         |         |
| [hand_right](#prop-hand-right)         | [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html)         |         |

## Methods

| Returns | Name                                                                                                                                                                                                                                                                                                       |
| ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| void    | [_init](#-init) ( hand_left: [OpenXRHand](https://docs.godotengine.org/de/4.x/classes/class_openxrhand.html), hand_right: [OpenXRHand](https://docs.godotengine.org/de/4.x/classes/class_openxrhand.html), finger_areas: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html) ) |
| void    | [_on_body_entered](#-on-body-entered) ( finger_type: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html), body: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) )                                                                                          |
| void    | [_on_body_exited](#-on-body-exited) ( finger_type: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html), body: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) )                                                                                            |
| void    | [_physics_process](#-physics-process) ( _delta: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) )                                                                                                                                                                                |
| void    | [_ready](#-ready) (  )                                                                                                                                                                                                                                                                                     |





## Constants

### Finger = `<Object>` {#const-Finger}

No description provided yet.

## Property Descriptions

### bodies_entered: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#prop-bodies-entered}

Record<TouchBody3D, Array<Finger.Type>>

### finger_areas: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html) {#prop-finger-areas}

Record<Finger.Type, Area3D>

### hand_left: [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html) {#prop-hand-left}

No description provided yet.

### hand_right: [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html) {#prop-hand-right}

No description provided yet.

## Method Descriptions

###  _init (hand_left: [OpenXRHand](https://docs.godotengine.org/de/4.x/classes/class_openxrhand.html) , hand_right: [OpenXRHand](https://docs.godotengine.org/de/4.x/classes/class_openxrhand.html) , finger_areas: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html)  ) -> void {#-init}

No description provided yet.

###  _on_body_entered (finger_type: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) , body: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html)  ) -> void {#-on-body-entered}

No description provided yet.

###  _on_body_exited (finger_type: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) , body: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html)  ) -> void {#-on-body-exited}

No description provided yet.

###  _physics_process (_delta: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html)  ) -> void {#-physics-process}

No description provided yet.

###  _ready ( ) -> void {#-ready}

No description provided yet.
