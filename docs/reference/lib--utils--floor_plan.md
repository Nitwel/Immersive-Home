# FloorPlan
**Inherits:** [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)

## Description

Builds the floor plan that is synced to the home automation system, so other apps can draw the rooms and the entities inside them in 2D or 3D.

The house store keeps everything in the headset's tracking space, which moves whenever tracking is recentered and the user fixes the align reference. The floor plan is instead expressed in the house frame, which the align reference defines and which therefore stays the same across sessions: origin: the first align corner, on the floor (y = 0) +X:     towards the second align corner +Y:     up +Z:     X cross Y (Godot's right-handed, Y-up convention) A 2D view uses the [x, z] floor coordinates. Units are meters, angles radians.  Format (version 1): version: int units: "m" heading: float, compass bearing in degrees (clockwise from north) the -Z axis points to rooms: [{name, height, polygon: [[x, z], ...]}] doors: [{id, rooms: [room1, room2], room1: [[x, y, z], [x, y, z]], room2: [[x, y, z], [x, y, z]]}] entities: [{id, room, interface, position: [x, y, z], rotation: [x, y, z], scale}] rotation is an Euler rotation in YXZ order, so rotation[1] is the yaw.

## Methods

| Returns                                                                              | Name                                                                                                                                                                                                               |
| ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [float](https://docs.godotengine.org/en/stable/classes/class_float.html)             | [_get_heading](#-get-heading) ( state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), frame: [Transform3D](https://docs.godotengine.org/en/stable/classes/class_transform3d.html) ) |
| [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)             | [_point](#-point) ( value: [Vector3](https://docs.godotengine.org/en/stable/classes/class_vector3.html) )                                                                                                          |
| [float](https://docs.godotengine.org/en/stable/classes/class_float.html)             | [_round](#-round) ( value: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) )                                                                                                              |
| [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)   | [build](#build) ( state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) )                                                                                                            |
| [Transform3D](https://docs.godotengine.org/en/stable/classes/class_transform3d.html) | [get_house_frame](#get-house-frame) ( state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) )                                                                                        |

## Constants

### PRECISION = `0.001` {#const-PRECISION}

Coordinates are rounded to millimeters, finer is noise from the hand tracking.

### VERSION = `1` {#const-VERSION}

No description provided yet.

## Method Descriptions

### static _get_heading (state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , frame: [Transform3D](https://docs.godotengine.org/en/stable/classes/class_transform3d.html)  ) -> [float](https://docs.godotengine.org/en/stable/classes/class_float.html) {#-get-heading}

The house store's map_heading is the bearing of tracking space's -Z axis, turn it into the bearing of the house frame's -Z axis.

### static _point (value: [Vector3](https://docs.godotengine.org/en/stable/classes/class_vector3.html)  ) -> [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) {#-point}

No description provided yet.

### static _round (value: [float](https://docs.godotengine.org/en/stable/classes/class_float.html)  ) -> [float](https://docs.godotengine.org/en/stable/classes/class_float.html) {#-round}

No description provided yet.

### static build (state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)  ) -> [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#build}

Builds the floor plan from the state of the house store.

### static get_house_frame (state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)  ) -> [Transform3D](https://docs.godotengine.org/en/stable/classes/class_transform3d.html) {#get-house-frame}

The house frame in tracking space: transforms house coordinates to tracking space.
