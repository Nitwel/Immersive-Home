# Finger
**Inherits:** [RefCounted](https://docs.godotengine.org/en/stable/classes/class_refcounted.html)

## Description

Description of a finger area.

## Properties

| Name                                         | Type                                                                         | Default |
| -------------------------------------------- | ---------------------------------------------------------------------------- | ------- |
| [area](#prop-area)                           | [Area3D](https://docs.godotengine.org/en/stable/classes/class_area3d.html)   |         |
| [previous_position](#prop-previous-position) | [Vector3](https://docs.godotengine.org/en/stable/classes/class_vector3.html) |         |
| [type](#prop-type)                           | [Finger.Type](/reference/lib--utils--touch--finger.html#enum-Type)           |         |

## Enums

### enum Type {#enum-Type}

#### Type.THUMB_RIGHT = `0` {#const-THUMB-RIGHT}

No description provided yet.

#### Type.INDEX_RIGHT = `1` {#const-INDEX-RIGHT}

No description provided yet.

#### Type.MIDDLE_RIGHT = `2` {#const-MIDDLE-RIGHT}

No description provided yet.

#### Type.RING_RIGHT = `3` {#const-RING-RIGHT}

No description provided yet.

#### Type.LITTLE_RIGHT = `4` {#const-LITTLE-RIGHT}

No description provided yet.

#### Type.THUMB_LEFT = `5` {#const-THUMB-LEFT}

No description provided yet.

#### Type.INDEX_LEFT = `6` {#const-INDEX-LEFT}

No description provided yet.

#### Type.MIDDLE_LEFT = `7` {#const-MIDDLE-LEFT}

No description provided yet.

#### Type.RING_LEFT = `8` {#const-RING-LEFT}

No description provided yet.

#### Type.LITTLE_LEFT = `9` {#const-LITTLE-LEFT}

No description provided yet.

## Property Descriptions

### area: [Area3D](https://docs.godotengine.org/en/stable/classes/class_area3d.html) {#prop-area}

No description provided yet.

### previous_position: [Vector3](https://docs.godotengine.org/en/stable/classes/class_vector3.html) {#prop-previous-position}

Global position of [`area`](#prop-area) at the last physics tick where it was somewhere else. Lets receivers tell which side a touch came from, which the current position can't do when the finger moves far in a single tick.

### type: [Finger.Type](/reference/lib--utils--touch--finger.html#enum-Type) {#prop-type}

No description provided yet.
