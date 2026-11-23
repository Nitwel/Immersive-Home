# Integration with Home Assistant

The Immersive Home integration connects your headsets with Home Assistant. Installing it is optional, but it adds:

- a **Room** sensor for every headset that shows which room you are in, so you can build automations based on where you are in your home,
- a **floor plan sync**: the rooms, doors and devices you set up in the headset are sent to Home Assistant,
- two dashboard cards that show your floor plan with the live state of your devices: a [2D floor plan and a 3D dollhouse](#floor-plan-cards).

The app detects the integration automatically. Each headset is added as its own device when the app connects, and stays set up after Home Assistant restarts.

![Integration inside Home Assistant](/img/ha-integration.png)

The integration needs Home Assistant 2024.7 or newer.

## Installation

### With HACS

1. Open HACS in Home Assistant.
2. Open the menu in the top right and select **Custom repositories**.
3. Add `https://github.com/Nitwel/Immersive-Home` with the type **Integration**.
4. Search for **Immersive Home** in HACS and download it.
5. Restart Home Assistant.

### Manually

1. Download the latest release from [GitHub](https://github.com/Nitwel/Immersive-Home/releases/latest/download/Integration.zip).
2. Extract the zip file into a folder called `immersive_home` in the `custom_components` folder of your Home Assistant instance.
3. Restart Home Assistant.

### Adding the Integration

1. Go to **Settings → Devices & services** and click **Add integration**.
2. Search for **Immersive Home** and confirm.

This only has to be done once. It makes Home Assistant load the integration, so your headsets can add themselves.

### Connecting the Headset

Start the app and connect it to Home Assistant. The headset registers itself and shows up under **Settings → Devices & services → Immersive Home** as its own device. You don't need to add headsets by hand.

::: tip Upgrading from an older version
Older versions needed an `immersive_home:` line in `configuration.yaml`. It still works: the integration is set up from it automatically, and Home Assistant shows a repair notice. You can then remove the line from `configuration.yaml` and restart.

Older versions could also create a second "Immersive Home" entry for the same headset. If you see duplicate entries after upgrading, delete them and let the headset register again.
:::

## Room Sensor

Every headset gets a **Room** sensor that shows the name of the room the headset is in. It keeps its last value when Home Assistant restarts.

## Floor Plan Sync

When you save your rooms, doors or placed devices in the app, the headset sends the floor plan to Home Assistant a few seconds later. There is one floor plan per home: the last headset that synced replaces it. A headset without any rooms never overwrites it.

## Floor Plan Cards

The integration ships two dashboard cards. They are loaded automatically, you don't need to add a resource. Add them from the card picker in the dashboard editor or with YAML. Both cards have a visual editor.

Both cards:

- show lights that are on in their colour, and other active devices in Home Assistant's active colour,
- show sensor values under their markers,
- open the entity's details when you click a marker,
- highlight the rooms a headset is in,
- push markers that would overlap apart and draw a line to their real position,
- can colour the rooms by **temperature** or **humidity**, using the temperature and humidity sensors and climate entities placed in each room. The scales are 16–30 °C and 20–80 %, the same as in the app's [Map View](/getting-started/map-view). Switch between the maps with the buttons below the plan.

### 2D Floor Plan

```yaml
type: custom:immersive-home-floor-plan-card
title: Home
north_up: false        # turn the plan so north is up
rotation: 0            # degrees clockwise, when north_up is off
show_compass: true
show_room_names: true
show_headsets: true    # highlight the rooms a headset is in
overlay: none          # none, temperature or humidity
hide_entities: []      # placed entities not to show
```

### 3D Dollhouse

```yaml
type: custom:immersive-home-floor-plan-3d-card
title: Home
pitch: 55              # degrees the view looks down, 15 (side) to 90 (top)
rotation: 30           # starting turn in degrees, when north_up is off
aspect_ratio: 1.333    # width / height of the view
show_lighting: true    # lights that are on light up their room
# plus all the options of the 2D card
```

The 3D card shows your rooms at their real height with door openings, and devices at the height you placed them.

- **Turn and tilt:** drag, or use the arrow keys.
- **Zoom:** scroll wheel, trackpad or pinch, or the `+` and `-` keys.
- **Pan:** right-drag, shift-drag or drag with two fingers.
- **Reset:** double-click, press Home or use the reset button.

On touch screens a horizontal swipe turns the house and a vertical swipe scrolls the page.
