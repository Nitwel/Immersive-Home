![logo](assets/banner.png)

#  🏠 Introduction

Immersive Home is project to bring Smart Home and Mixed Reality technologies together for an intuitive and immersive experience. [Demo Video](https://www.youtube.com/watch?v=vk6uTYOINY4)

## Planned Features

- **Fast and Intuitive control over IoT devices**
- **Live overview over your smart home**
- **Simple way for creating automations**
- **Comfortable way of consuming virtual media unobstructed**
- **Advanced automations based on position in room**

## Try it out

Right now you can try out the app for free using either of the following pages:

<a href="https://www.oculus.com/experiences/quest/7533875049973382/" target="_blank">
	<img height="32" src="assets/badges/meta.svg" alt="Badge linking to Meta App Lab" />
</a>

<a href="https://github.com/Nitwel/Immersive-Home/releases/latest/download/Android.zip" target="_blank">
	<img height="32" src="assets/badges/github.svg" alt="Badge linking to GitHub" />
</a>

<a href="https://nitwel.itch.io/immersive-home" target="_blank">
	<img height="32" src="assets/badges/itch.svg" alt="Badge linking to itch.io" />
</a>

<a href="https://sidequestvr.com/app/26827/immersive-home" target="_blank">
	<img height="32" src="assets/badges/sidequest.svg" alt="Badge linking to sidequest" />
</a>

💕 If you like to see the project grow to support more devices and interaction methods, consider supporting the project using these methods:

- Donate using [PayPal]( https://paypal.me/nitwel) or [GitHub Sponsors](https://github.com/sponsors/Nitwel)
- Buying the app on [Meta App Lab](https://www.oculus.com/experiences/quest/7533875049973382/) or [itch.io](https://nitwel.itch.io/immersive-home)
- Contributing to the project by creating issues or pull requests

## Supported Devices

**Smart Home Platforms**
- [Home Assistant](https://www.home-assistant.io/)

**Mixed Reality Headsets**
- Meta Quest 2 / Pro / 3

## Connecting to your Home Assistant Instance
Go to the settings tab (the gear icon) and enter the url of your Home Assistant instance.
In order to authenticate, you have to generate a long-lived access token in Home Assistant.
To generate a HASS token, login into your dashboard, click on your name (bottom left), scroll down and create a long-lived access token.

Finally, click the connect button and you should be connected to your Home Assistant instance.

# 🛠 Development

In order to contribute to this project, you need the following to be setup before you can start working:
- Godot 4.1.3 installed

## Fundamentals

Communication with the Smart Home Environment is done using the `HomeApi` global. Each environment is made up of devices and entities.
A device is a collection of different entities and entities can represent many different things in a smart home.
For example, the entity of name `lights.smart_lamp_1` would control the kitchen lamps while `state.smart_lamp_1_temp` would show the current temperature of the lamp.

### File Structure

```
.
├── addons             (All installed Godot Addons are saved here)
├── assets             (Files like logos or assets that are shared across scenes)
├── content/           (Main files of the project)
│   ├── entities       (Entities that can be placed into the room)
│   ├── functions      (Generic functions that can be used in scenes)
│   └── ui             (User Interface Scenes and related files)
└── lib/               (Code that is global or shared across scenes)
    ├── globals        (Globally running scripts)
    └── home_adapters  (Code allowing control smart home entities)
```

### Home Api

The `HomeApi` global allows to communicate with different backends and offers a set of fundamental functions allowing communication with the Smart Home.

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

It is also possible to bubble up information by returning a dictionary from a function like `_on_click`.

| Function called | Args | Description |
| -- | -- | -- |
| `_on_click` | `[event: EventPointer]` | The back trigger button has been pressed and released |
| `_on_press_down` | `[event: EventPointer]` | The back trigger button has been pressed down |
| `_on_press_move` | `[event: EventPointer]` | The back trigger button has been moved while pressed down |
| `_on_press_up` | `[event: EventPointer]` | The back trigger button has been released |
| `_on_grab_down` | `[event: EventPointer]` | The side grab button been pressed down |
| `_on_grab_move` | `[event: EventPointer]` | The side grab button been pressed down |
| `_on_grab_up` | `[event: EventPointer]` | The side grab button been released |
| `_on_ray_enter` | `[event: EventPointer]` | The ray-cast enters the the collision body |
| `_on_ray_leave` | `[event: EventPointer]` | The ray-cast leaves the the collision body |
| `_on_key_down` | `[event: EventKey]` | The ray-cast leaves the the collision body |
| `_on_key_up` | `[event: EventKey]` | The ray-cast leaves the the collision body |
| `_on_focus_in` | `[event: EventFocus]` | The node is got focused |
| `_on_focus_out` | `[event: EventFocus]` | The node lost focus |

After considering using the build in godot event system, I've decided that it would be better to use a custom event system.
The reason being that we would have to check each tick if the event matches the desired one which seems very inefficient compared to using signals like the browser does.
Thus I've decided to use a custom event system that is similar to the one used in the browser.

### UI Groups

| Group | Description |
| -- | -- |
| `entity` | Marks the object as being an entity placed in space |
| `ui_focus` | The element can be focused, can be a parent |
| `ui_focus_skip` | Focus checking on this element will be skipped |
| `ui_focus_stop` | The focus will not be reset. Useful for keyboard |

### Saving and Loading

In order for an entity to be saved, it has to implement the `_save` function returning a dictionary of the data that should be saved.
When loading, first the saved node gets instantiated, then either the `_load` function is called with the saved data, or when no `_load` function is implemented, the saved data directly applied to the node.

### Functions

In order to implement generic features, a set of functions is available to be used in the project.

#### Movable

The `Movable` node allows to move a node around in the room. It uses the grab events in order to transform the parent node.

#### Clickable

The `Clickable` allows to access events of the parent using signals this node emits.

## Installing Locally
1. Make sure Git LFS is installed
2. Run `git clone https://github.com/Nitwel/Immersive-Home.git` in your terminal
3. Import the created `Immersive-Home` folder in Godot
4. Open the project in Godot 4.1.3

### Testing without a VR Headset

In order to test without a headset, press the run project (F5) button in Godot and ignore the prompt that OpenXR failed to start.
To simulate the headset and controller movement, we're using the [XR Input Simulator](https://godotengine.org/asset-library/asset/1775) asset.
Click at the link to get a list of the supported controls.

## Building

1. Possibly fix importing scenes error
2. Follow the following guide to setup exporting for android. [link](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)
3. Make sure to reuse any existing `debug.keystore` when updating an app
4. Don't forget to set the JAVA_HOME variable and restart Godot to take effect
5. Install the `Godot XR Android OpenXR Loaders` plugin in Godot
6. Configure the following in the android build template:
	- XRMode set to OpenXR
	- Check `Use Grandle Build`
	- Check `Godot OpenXR Meta`
	- In XRFeatures, select at least optional for passthrough
	- Ckeck Internet under the permissions
	- Under Resources > Filters to export, add `*.j2`
7. `<uses-feature android:name="com.oculus.feature.CONTEXTUAL_BOUNDARYLESS_APP" android:required="true" />` can be added to the `AndroidManifest.xml` to disable the boundary system.

## Troubleshooting

- If you encounter unexpected behavior when building compared to running locally, it may be that the cached data of godot is corrupted or outdated. Try deleting the `.godot` folder and / or all `*.import` files.