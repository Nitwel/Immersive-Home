# Collide
**Inherits:** [Node3D](https://docs.godotengine.org/en/stable/classes/class_node3d.html)

## Description

Calculates collision for fingers and FingerAreas

## Properties

| Name                                     | Type                                                                                 | Default |
| ---------------------------------------- | ------------------------------------------------------------------------------------ | ------- |
| [finger_type](#prop-finger-type)         | [Finger.Type](/reference/lib--utils--touch--finger.html#enum-Type)                   |         |
| [hand](#prop-hand)                       | [Node3D](https://docs.godotengine.org/en/stable/classes/class_node3d.html)           |         |
| [hand_mesh](#prop-hand-mesh)             | [Node3D](https://docs.godotengine.org/en/stable/classes/class_node3d.html)           |         |
| [last_run_active](#prop-last-run-active) | [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)         | `false` |
| [tip](#prop-tip)                         | [Node3D](https://docs.godotengine.org/en/stable/classes/class_node3d.html)           |         |
| [tip_body](#prop-tip-body)               | [RigidBody3D](https://docs.godotengine.org/en/stable/classes/class_rigidbody3d.html) |         |

## Methods

| Returns                                                                      | Name                                                                                                                                                                                                                                                                                                                                                          |
| ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| void                                                                         | [_init](#-init) ( hand: [Node3D](https://docs.godotengine.org/en/stable/classes/class_node3d.html), hand_mesh: [Node3D](https://docs.godotengine.org/en/stable/classes/class_node3d.html), tip: [Node3D](https://docs.godotengine.org/en/stable/classes/class_node3d.html), finger_type: [Finger.Type](/reference/lib--utils--touch--finger.html#enum-Type) ) |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) | [_move_tip_rigidbody_to_bone](#-move-tip-rigidbody-to-bone) ( tip_rigidbody: [RigidBody3D](https://docs.godotengine.org/en/stable/classes/class_rigidbody3d.html), tip_bone: [Node3D](https://docs.godotengine.org/en/stable/classes/class_node3d.html) )                                                                                                     |
| void                                                                         | [_physics_process](#-physics-process) ( _delta: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) )                                                                                                                                                                                                                                |
| void                                                                         | [_ready](#-ready) (  )                                                                                                                                                                                                                                                                                                                                        |

## Constants

### Finger = `<Object>` {#const-Finger}

No description provided yet.

### TipCollider = `<Object>` {#const-TipCollider}

No description provided yet.

## Property Descriptions

### finger_type: [Finger.Type](/reference/lib--utils--touch--finger.html#enum-Type) {#prop-finger-type}

No description provided yet.

### hand: [Node3D](https://docs.godotengine.org/en/stable/classes/class_node3d.html) {#prop-hand}

No description provided yet.

### hand_mesh: [Node3D](https://docs.godotengine.org/en/stable/classes/class_node3d.html) {#prop-hand-mesh}

No description provided yet.

### last_run_active: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#prop-last-run-active}

No description provided yet.

### tip: [Node3D](https://docs.godotengine.org/en/stable/classes/class_node3d.html) {#prop-tip}

No description provided yet.

### tip_body: [RigidBody3D](https://docs.godotengine.org/en/stable/classes/class_rigidbody3d.html) {#prop-tip-body}

No description provided yet.

## Method Descriptions

### _init (hand: [Node3D](https://docs.godotengine.org/en/stable/classes/class_node3d.html) , hand_mesh: [Node3D](https://docs.godotengine.org/en/stable/classes/class_node3d.html) , tip: [Node3D](https://docs.godotengine.org/en/stable/classes/class_node3d.html) , finger_type: [Finger.Type](/reference/lib--utils--touch--finger.html#enum-Type)  ) -> void {#-init}

No description provided yet.

### _move_tip_rigidbody_to_bone (tip_rigidbody: [RigidBody3D](https://docs.godotengine.org/en/stable/classes/class_rigidbody3d.html) , tip_bone: [Node3D](https://docs.godotengine.org/en/stable/classes/class_node3d.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-move-tip-rigidbody-to-bone}

No description provided yet.

### _physics_process (_delta: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)  ) -> void {#-physics-process}

No description provided yet.

### _ready ( ) -> void {#-ready}

No description provided yet.
