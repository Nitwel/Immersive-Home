![logo](assets/banner.png)

#  🏠 Introduction

Immersive Home is project to bring Smart Home and Mixed Reality technologies together for an intuitive and immersive experience.

## Features

- **Fast and Intuitive control over IoT devices**
- **Live overview over your smart home**
- **Simple way for creating automations**
- **Comfortable way of consuming virtual media unobstructed**
- **Advanced automations based on position in room**

## Supported Devices

**Smart Home Platforms**
- [Home Assistant](https://www.home-assistant.io/)

**Mixed Reality Headsets**
- Meta Quest 2 / Pro / 3

# 🛠 Development

In order to contribute to this project, you need the following to be setup before you can start working:
- Godot 4.1.3 installed

## Fundamentals

Communication with the Smart Home Environment is done using the `HomeAdapters` global. Each environment is made up of devices and entities.
A device is a collection of different entities and entities can represent many different things in a smart home.
For example, the entity of name `lights.smart_lamp_1` would control the kitchen lamps while `state.smart_lamp_1_temp` would show the current temperature of the lamp.

### File Structure

```
.
├── addons             (All installed Godot Addons are saved here)
├── assets             (Files like logos or assets that are shared across scenes)
├── content/           (Main files of the project)
│   ├── entities       (Entities that can be placed into the room)
│   └── ui             (User Interface Scenes and related files)
└── lib/               (Code that is global or shared across scenes)
    ├── globals        (Globally running scripts)
    └── home_adapters  (Code allowing control smart home entities)
```

### Home Adapters

The `HomeAdapters` global allows to communicate with different backends and offers a set of fundamental functions allowing communication with the Smart Home.

```python
Device {
	"id": String,
	"name": String,
	"entities": Array[Entity]
}

Entity {
	"state": String
	"attributes": Dictionary
}

# Get a list of all devices
func get_devices() -> Signal[Array[Device]]

# Get a single device by id
func get_device(id: String) -> Signal[Device]

# Returns the current state of an entity.
func get_state(entity: String) -> Signal[Entity]

# Updates the state of the entity and returns the resulting state
func set_state(entity: String, state: String, attributes: Dictionary) -> Signal[Entity]

# Watches the state and each time it changes, calls the callback with the changed state, returns a function to stop watching the state
func watch_state(entity: String, callback: Callable[entity: Entity]) -> Callable
```

### Interaction Events

Each time a button is pressed on the primary controller, a ray-cast is done to be able to interact with devices or the UI.
Additionally, each event will bubble up until the root node is reached, allowing to handle events on parents.
In case that an event of a specific node has to be reacted on, use the `Clickable` function node.

```python
InteractionEvent {
	"controller": XRController3D, # The controller that triggered the event
	"ray": RayCast3D, # The ray-cast that triggered the event
	"target": Node3D, # The node that was hit by the ray-cast
}
```

| Function called | Args | Description |
| -- | -- | -- |
| `_on_click` | `[event: InteractionEvent]` | The back trigger button has been pressed and released |
| `_on_press_down` | `[event: InteractionEvent]` | The back trigger button has been pressed down |
| `_on_press_move` | `[event: InteractionEvent]` | The back trigger button has been moved while pressed down |
| `_on_press_up` | `[event: InteractionEvent]` | The back trigger button has been released |
| `_on_grab_down` | `[event: InteractionEvent]` | The side grab button been pressed down |
| `_on_grab_move` | `[event: InteractionEvent]` | The side grab button been pressed down |
| `_on_grab_up` | `[event: InteractionEvent]` | The side grab button been released |
| `_on_ray_enter` | `[event: InteractionEvent]` | The ray-cast enters the the collision body |
| `_on_ray_leave` | `[event: InteractionEvent]` | The ray-cast leaves the the collision body |

### Functions

In order to implement generic features, a set of functions is available to be used in the project.

#### Movable

The `Movable` node allows to move a node around in the room. It uses the grab events in order to transform the parent node.

#### Clickable

The `Clickable` allows to access events of the parent using signals this node emits.

### Testing without a VR Headset

In order to test without a headset, press the run project (F5) button in Godot and ignore the prompt that OpenXR failed to start.
To simulate the headset and controller movement, we're using the [XR Input Simulator](https://godotengine.org/asset-library/asset/1775) asset.
Click at the link to get a list of the supported controls.
