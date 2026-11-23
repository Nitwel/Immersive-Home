# Demo
**Inherits:** [SimulatedApi](/reference/lib--home_apis--demo--simulated_api.html)

## Description

Adapter for the demo mode: a made-up home with fake devices, so the app can be shown without a Home Assistant server.

Services are simulated by the base class (toggling a light turns it on). On top of that, sensors drift a little, the bathroom gets steamy now and then, and two people travel around the city on fixed routes, so their position history and live position always match. The rooms the devices are placed in come from demo_house.gd. Everything here is made up: names, places and devices.

## Properties

| Name                           | Type                                                                               | Default |
| ------------------------------ | ---------------------------------------------------------------------------------- | ------- |
| [_baselines](#prop--baselines) | [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | `{}`    |

## Methods

| Returns                                                                            | Name                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| ---------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | [_device](#-device) ( id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), name: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), area: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), model: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), entity_ids: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) ) |
| [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)           | [_devices](#-devices) (  )                                                                                                                                                                                                                                                                                                                                                                                                                            |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_drift_sensors](#-drift-sensors) (  )                                                                                                                                                                                                                                                                                                                                                                                                                |
| void                                                                               | [_init](#-init) ( _url: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) = `""`, _token: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) = `""` )                                                                                                                                                                                                                                                |
| [String](https://docs.godotengine.org/en/stable/classes/class_string.html)         | [_iso](#-iso) ( unix: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) )                                                                                                                                                                                                                                                                                                                                                      |
| [String](https://docs.godotengine.org/en/stable/classes/class_string.html)         | [_local](#-local) ( unix: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) )                                                                                                                                                                                                                                                                                                                                                  |
| [float](https://docs.godotengine.org/en/stable/classes/class_float.html)           | [_meters](#-meters) ( a: [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html), b: [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html) )                                                                                                                                                                                                                                                              |
| void                                                                               | [_ready](#-ready) (  )                                                                                                                                                                                                                                                                                                                                                                                                                                |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_route_of](#-route-of) ( entity_id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                                                                                                                                                                                                                                                     |
| [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | [_sensor](#-sensor) ( name: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), value: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), unit: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), device_class: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                               |
| [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | [_states](#-states) (  )                                                                                                                                                                                                                                                                                                                                                                                                                              |
| [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)           | [_street_path](#-street-path) ( stops: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) )                                                                                                                                                                                                                                                                                                                                     |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_tick](#-tick) (  )                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_update_people](#-update-people) (  )                                                                                                                                                                                                                                                                                                                                                                                                                |
| [String](https://docs.godotengine.org/en/stable/classes/class_string.html)         | [_zone_state](#-zone-state) ( position: [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html) )                                                                                                                                                                                                                                                                                                                                |
| [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | [get_state_history](#get-state-history) ( entity_ids: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html), start: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), end: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) = `null` )                                                                                                                                       |
| [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html)       | [route_position](#route-position) ( route: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html), unix: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) )                                                                                                                                                                                                                                       |

## Constants

### HISTORY_STEP = `120.0` {#const-HISTORY-STEP}

Seconds between two recorded positions in the position history.

### HOME = `Vector2(52.5163, 13.3777)` {#const-HOME}

Made-up home location near a public landmark (Brandenburg Gate, Berlin), the same one the entity gallery uses. Vector2(latitude, longitude).

### HOME_RADIUS = `100.0` {#const-HOME-RADIUS}

No description provided yet.

### ROUTES = `{"person.alex": {"home_share": 0.55, "offset": 0.0, "period": 10800.0, "stops": [...], "tracker": "device_tracker.alex_phone"}, "person.sam": {"home_share": 0.3, "offset": 1800.0, "period": 5400.0, "stops": [...], "tracker": "device_tracker.sam_phone"}}` {#const-ROUTES}

Where the demo people go. Every `period` seconds a person spends `home_share` of the time at home, then visits the stops and comes back. `offset` shifts the schedule, so the two aren't in sync.

### TICK = `5.0` {#const-TICK}

Seconds between two simulated updates.

### ZONES = `{"zone.gym": ["Gym", Vector2(52.5079, 13.3933), 80.0], "zone.work": ["Work", Vector2(52.5251, 13.3694), 150.0]}` {#const-ZONES}

Zones besides home: entity id -> [name, position, radius in meters].

## Property Descriptions

### _baselines: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#prop--baselines}

Temperature/humidity sensor id -> the value it drifts around.

## Method Descriptions

### _device (id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , name: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , area: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , model: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , entity_ids: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)  ) -> [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#-device}

No description provided yet.

### _devices ( ) -> [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) {#-devices}

Devices for the Widgets panel. Entities that belong to no device are grouped per domain, like the Home Assistant adapter does.

### _drift_sensors ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-drift-sensors}

Sensors wander around their baseline. Now and then someone showers, which sends the bathroom humidity up; it slowly settles afterwards.

### _init (_url: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) = `""` , _token: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) = `""`  ) -> void {#-init}

No description provided yet.

### static _iso (unix: [float](https://docs.godotengine.org/en/stable/classes/class_float.html)  ) -> [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#-iso}

UTC timestamp like Home Assistant's last_changed.

### static _local (unix: [float](https://docs.godotengine.org/en/stable/classes/class_float.html)  ) -> [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#-local}

Local wall-clock time like calendar start_time ("2026-11-20 10:00:00").

### static _meters (a: [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html) , b: [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html)  ) -> [float](https://docs.godotengine.org/en/stable/classes/class_float.html) {#-meters}

No description provided yet.

### _ready ( ) -> void {#-ready}

No description provided yet.

### _route_of (entity_id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-route-of}

No description provided yet.

### static _sensor (name: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , value: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , unit: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , device_class: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#-sensor}

No description provided yet.

### _states ( ) -> [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#-states}

No description provided yet.

### static _street_path (stops: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)  ) -> [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) {#-street-path}

Goes north/south first and then east/west between stops, so paths look like they follow streets instead of cutting straight through blocks.

### _tick ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-tick}

No description provided yet.

### _update_people ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-update-people}

No description provided yet.

### static _zone_state (position: [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html)  ) -> [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#-zone-state}

Home Assistant's state for a tracker at `position`: home, a zone name or not_home.

### get_state_history (entity_ids: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) , start: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , end: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) = `null`  ) -> [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#get-state-history}

The people's recorded positions come from their routes, so the path on the map ends exactly where they are now.

### static route_position (route: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) , unix: [float](https://docs.godotengine.org/en/stable/classes/class_float.html)  ) -> [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html) {#route-position}

Where someone on `route` is at `unix` time.
