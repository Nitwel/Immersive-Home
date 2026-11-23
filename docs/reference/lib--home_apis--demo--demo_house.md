# DemoHouse
**Inherits:** [RefCounted](https://docs.godotengine.org/en/stable/classes/class_refcounted.html)

## Description

The ready-made apartment of the demo mode, with the demo devices already placed.

Laid out in a frame where the user stands at the origin, in the middle of the living room, looking towards -Z. build() turns it into a house store state around the given spot, so the rooms are built around wherever demo mode starts.  -Z +------------+ +--------+ |  Bedroom   | |Bathroom| +---door-----+ +--door--+ +-------------------------+ +---------+ |                         | | Kitchen | |   Living Room   (you)  door         | |                         | +---------+ +-------------------------+ +Z

## Methods

| Returns                                                                              | Name                                                                                                                                                                                                                                                                                            |
| ------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html)         | [_center](#-center) ( room_name: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                                                                                                   |
| [Transform3D](https://docs.godotengine.org/en/stable/classes/class_transform3d.html) | [_flatten](#-flatten) ( origin: [Transform3D](https://docs.godotengine.org/en/stable/classes/class_transform3d.html) )                                                                                                                                                                          |
| [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html)         | [_floor](#-floor) ( frame: [Transform3D](https://docs.godotengine.org/en/stable/classes/class_transform3d.html), corner: [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html) )                                                                                         |
| [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html)         | [_wall_normal](#-wall-normal) ( room_name: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), start: [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html), end: [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html) ) |
| [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)   | [build](#build) ( origin: [Transform3D](https://docs.godotengine.org/en/stable/classes/class_transform3d.html) )                                                                                                                                                                                |

## Constants

### DOORS = `[["Living Room", "Kitchen", Vector2(2.4, -1.4), Vector2(2.4, -0.5)], ["Living Room", "Bedroom", Vector2(-1.6, -2.2), Vector2(-0.7, -2.2)], ["Living Room", "Bathroom", Vector2(1.4, -2.2), Vector2(2.2, -2.2)]]` {#const-DOORS}

[room 1, room 2, door start, door end]: a door in the wall between two rooms, from start to end on room 1's side. Room 2's side is the matching spot on its wall.

### DOOR_HEIGHT = `2.05` {#const-DOOR-HEIGHT}

No description provided yet.

### ENTITIES = `[["light.living_room_ceiling", "Living Room", Vector3(0, 2.3, 0.2)], ["light.living_room_floor_lamp", "Living Room", Vector3(-2.2, 1.6, 1.9)], ["media_player.living_room_speaker", "Living Room", Vector3(-1.6, 1.4, 2.2)], ["climate.living_room_thermostat", "Living Room", Vector3(-2.5, 1.45, -0.4)], ["sensor.living_room_temperature", "Living Room", Vector3(-2.5, 1.45, 0.4)], ["sensor.living_room_humidity", "Living Room", Vector3(-2.5, 1.3, 0.4)], ["cover.living_room_blinds", "Living Room", Vector3(0.9, 1.4, 2.2)], ["binary_sensor.balcony_door", "Living Room", Vector3(1.8, 1.4, 2.2)], ["person.sam", "Living Room", Vector3(-0.3, 1.45, -2.1)], ["weather.home", "Living Room", Vector3(0.6, 1.45, -2.1)], ["lock.front_door", "Living Room", Vector3(2.3, 1.3, 1.6)], ["light.kitchen_spots", "Kitchen", Vector3(4, 2.3, -0.7)], ["switch.coffee_machine", "Kitchen", Vector3(5.4, 1.2, -1)], ["timer.oven", "Kitchen", Vector3(5.4, 1.45, -0.2)], ["sensor.kitchen_temperature", "Kitchen", Vector3(4, 1.45, -2.1)], ["sensor.kitchen_humidity", "Kitchen", Vector3(4, 1.3, -2.1)], ["sensor.dishwasher_status", "Kitchen", Vector3(3.2, 1, 0.7)], ["binary_sensor.kitchen_window", "Kitchen", Vector3(4.6, 1.5, 0.7)], ["todo.shopping_list", "Kitchen", Vector3(3.1, 1.45, -2.1)], ["light.bedside_lamp", "Bedroom", Vector3(-2.2, 0.8, -5.9)], ["cover.bedroom_curtains", "Bedroom", Vector3(-0.9, 1.4, -6.2)], ["sensor.bedroom_temperature", "Bedroom", Vector3(0.8, 1.45, -4.6)], ["sensor.bedroom_humidity", "Bedroom", Vector3(0.8, 1.3, -4.6)], ["humidifier.bedroom_humidifier", "Bedroom", Vector3(-2.5, 1, -3.4)], ["calendar.family", "Bedroom", Vector3(-2.5, 1.45, -4.6)], ["time.wake_up_alarm", "Bedroom", Vector3(-1.4, 1.2, -6.2)], ["light.bathroom_mirror", "Bathroom", Vector3(2.2, 1.9, -4.7)], ["fan.bathroom_fan", "Bathroom", Vector3(3.4, 1.9, -3.6)], ["sensor.bathroom_temperature", "Bathroom", Vector3(1.1, 1.45, -3.6)], ["sensor.bathroom_humidity", "Bathroom", Vector3(1.1, 1.3, -3.6)], ["water_heater.boiler", "Bathroom", Vector3(3.4, 1.4, -2.8)]]` {#const-ENTITIES}

[entity id, room, position (x, height, z)]. Widgets on a wall sit a little in front of it and face into their room.

### HEIGHT = `2.6` {#const-HEIGHT}

No description provided yet.

### ROOMS = `{"Bathroom": [Vector2(1, -4.8), Vector2(3.5, -2.3)], "Bedroom": [Vector2(-2.6, -6.3), Vector2(0.9, -2.3)], "Kitchen": [Vector2(2.5, -2.2), Vector2(5.5, 0.8)], "Living Room": [Vector2(-2.6, -2.2), Vector2(2.4, 2.3)]}` {#const-ROOMS}

Room name -> [min corner, max corner] on the floor (x, z), meters. The rooms are 10 cm apart, like the walls of a scanned home.

## Method Descriptions

### static _center (room_name: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html) {#-center}

No description provided yet.

### static _flatten (origin: [Transform3D](https://docs.godotengine.org/en/stable/classes/class_transform3d.html)  ) -> [Transform3D](https://docs.godotengine.org/en/stable/classes/class_transform3d.html) {#-flatten}

Only the floor position and the turn around the up axis of `origin`.

### static _floor (frame: [Transform3D](https://docs.godotengine.org/en/stable/classes/class_transform3d.html) , corner: [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html)  ) -> [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html) {#-floor}

No description provided yet.

### static _wall_normal (room_name: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , start: [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html) , end: [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html)  ) -> [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html) {#-wall-normal}

Unit vector from the wall a door is in, out of `room_name` (towards the room on the other side).

### static build (origin: [Transform3D](https://docs.godotengine.org/en/stable/classes/class_transform3d.html)  ) -> [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#build}

A house store state (see lib/stores/house.gd) with the apartment built around `origin`: its position on the floor and its turn around the up axis.
