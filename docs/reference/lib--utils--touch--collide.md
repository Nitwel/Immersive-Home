# Collide
**Inherits:** [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html)
    
## Description

Calculates collision for fingers and FingerAreas

## Properties

| Name                                     | Type                                                                                    | Default |
| ---------------------------------------- | --------------------------------------------------------------------------------------- | ------- |
| [hand_left](#prop-hand-left)             | [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html)                 |         |
| [hand_left_mesh](#prop-hand-left-mesh)   | [MeshInstance3D](https://docs.godotengine.org/de/4.x/classes/class_meshinstance3d.html) |         |
| [hand_right](#prop-hand-right)           | [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html)                 |         |
| [hand_right_mesh](#prop-hand-right-mesh) | [MeshInstance3D](https://docs.godotengine.org/de/4.x/classes/class_meshinstance3d.html) |         |
| [tip_left](#prop-tip-left)               | [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html)                 |         |
| [tip_left_body](#prop-tip-left-body)     | [RigidBody3D](https://docs.godotengine.org/de/4.x/classes/class_rigidbody3d.html)       |         |
| [tip_right](#prop-tip-right)             | [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html)                 |         |
| [tip_right_body](#prop-tip-right-body)   | [RigidBody3D](https://docs.godotengine.org/de/4.x/classes/class_rigidbody3d.html)       |         |

## Methods

| Returns | Name                                                                                                                                                                                                                                                                                                                                                                               |
| ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| void    | [_init](#-init) ( hand_left: [OpenXRHand](https://docs.godotengine.org/de/4.x/classes/class_openxrhand.html), hand_right: [OpenXRHand](https://docs.godotengine.org/de/4.x/classes/class_openxrhand.html), tip_left: [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html), tip_right: [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html) ) |
| void    | [_move_tip_rigidbody_to_bone](#-move-tip-rigidbody-to-bone) ( tip_rigidbody: [RigidBody3D](https://docs.godotengine.org/de/4.x/classes/class_rigidbody3d.html), tip_bone: [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html) )                                                                                                                                |
| void    | [_physics_process](#-physics-process) ( _delta: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) )                                                                                                                                                                                                                                                        |
| void    | [_ready](#-ready) (  )                                                                                                                                                                                                                                                                                                                                                             |





## Constants

### Finger = `<Object>` {#const-Finger}

No description provided yet.

### TipCollider = `<Object>` {#const-TipCollider}

No description provided yet.

## Property Descriptions

### hand_left: [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html) {#prop-hand-left}

No description provided yet.

### hand_left_mesh: [MeshInstance3D](https://docs.godotengine.org/de/4.x/classes/class_meshinstance3d.html) {#prop-hand-left-mesh}

No description provided yet.

### hand_right: [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html) {#prop-hand-right}

No description provided yet.

### hand_right_mesh: [MeshInstance3D](https://docs.godotengine.org/de/4.x/classes/class_meshinstance3d.html) {#prop-hand-right-mesh}

No description provided yet.

### tip_left: [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html) {#prop-tip-left}

No description provided yet.

### tip_left_body: [RigidBody3D](https://docs.godotengine.org/de/4.x/classes/class_rigidbody3d.html) {#prop-tip-left-body}

No description provided yet.

### tip_right: [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html) {#prop-tip-right}

No description provided yet.

### tip_right_body: [RigidBody3D](https://docs.godotengine.org/de/4.x/classes/class_rigidbody3d.html) {#prop-tip-right-body}

No description provided yet.

## Method Descriptions

###  _init (hand_left: [OpenXRHand](https://docs.godotengine.org/de/4.x/classes/class_openxrhand.html) , hand_right: [OpenXRHand](https://docs.godotengine.org/de/4.x/classes/class_openxrhand.html) , tip_left: [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html) , tip_right: [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html)  ) -> void {#-init}

No description provided yet.

###  _move_tip_rigidbody_to_bone (tip_rigidbody: [RigidBody3D](https://docs.godotengine.org/de/4.x/classes/class_rigidbody3d.html) , tip_bone: [Node3D](https://docs.godotengine.org/de/4.x/classes/class_node3d.html)  ) -> void {#-move-tip-rigidbody-to-bone}

No description provided yet.

###  _physics_process (_delta: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html)  ) -> void {#-physics-process}

No description provided yet.

###  _ready ( ) -> void {#-ready}

No description provided yet.
