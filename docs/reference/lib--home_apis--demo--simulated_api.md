# SimulatedApi
**Inherits:** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

## Description

In-memory stand-in for the Home Assistant adapter (lib/home_apis/hass_ws/hass.gd).

Implements the same interface HomeApi forwards to, so entities can run without a server. set_state() simulates what the matching Home Assistant service would do and notifies watchers, so toggling a light really turns it on. Used by the entity gallery (test/content/entities) and, extended, by the demo mode (./demo.gd).

## Properties

| Name                                       | Type                                                                               | Default |
| ------------------------------------------ | ---------------------------------------------------------------------------------- | ------- |
| [_cover_moves](#prop--cover-moves)         | [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | `{}`    |
| [calls](#prop-calls)                       | [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)           | `[]`    |
| [devices](#prop-devices)                   | [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)           | `[]`    |
| [entities](#prop-entities)                 | [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | `{}`    |
| [entity_callbacks](#prop-entity-callbacks) | [CallbackMap](/reference/CallbackMap.html)                                         |         |

## Methods

| Returns                                                                            | Name                                                                                                                                                                                                                                                                                                                                                                                                             |
| ---------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [String](https://docs.godotengine.org/en/stable/classes/class_string.html)         | [_format_duration](#-format-duration) ( seconds: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) )                                                                                                                                                                                                                                                                                      |
| void                                                                               | [_init](#-init) ( initial_states: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) = `{}` )                                                                                                                                                                                                                                                                                    |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_install_update](#-install-update) ( entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                                                                                                                                                                                                       |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_move_cover](#-move-cover) ( entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), move_id: [int](https://docs.godotengine.org/en/stable/classes/class_int.html), target: [int](https://docs.godotengine.org/en/stable/classes/class_int.html) )                                                                                                                                  |
| [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | [_normalize](#-normalize) ( state: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) )                                                                                                                                                                                                                                                                                          |
| [int](https://docs.godotengine.org/en/stable/classes/class_int.html)               | [_parse_duration](#-parse-duration) ( text: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) )                                                                                                                                                                                                                                                                                       |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_simulate_alarm](#-simulate-alarm) ( entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html), state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), service_data: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) )   |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_simulate_climate](#-simulate-climate) ( current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html), state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), service_data: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) )                                                                                   |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_simulate_cover](#-simulate-cover) ( entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html), state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), service_data: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) )   |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_simulate_fan](#-simulate-fan) ( current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html), state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), service_data: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) )                                                                                           |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_simulate_humidifier](#-simulate-humidifier) ( current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html), state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), service_data: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) )                                                                             |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_simulate_light](#-simulate-light) ( current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html), state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), service_data: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) )                                                                                       |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_simulate_lock](#-simulate-lock) ( entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html), state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) )                                                                                                       |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_simulate_media_player](#-simulate-media-player) ( current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html), state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), service_data: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) )                                                                         |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_simulate_timer](#-simulate-timer) ( current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html), state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) )                                                                                                                                                                                         |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_simulate_update](#-simulate-update) ( entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html), state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) )                                                                                                   |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_simulate_vacuum](#-simulate-vacuum) ( entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html), state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), service_data: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) ) |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_simulate_water_heater](#-simulate-water-heater) ( current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html), state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), service_data: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) )                                                                         |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [get_device](#get-device) ( _id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                                                                                                                                                                                                                    |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [get_devices](#get-devices) (  )                                                                                                                                                                                                                                                                                                                                                                                 |
| [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)           | [get_entity_ids](#get-entity-ids) ( domains: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) )                                                                                                                                                                                                                                                                                          |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [get_history](#get-history) ( entity_id: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), start: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), interval: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), _end: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) = `null` )                |
| [String](https://docs.godotengine.org/en/stable/classes/class_string.html)         | [get_http_url](#get-http-url) (  )                                                                                                                                                                                                                                                                                                                                                                               |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [get_state](#get-state) ( entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                                                                                                                                                                                                                   |
| [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | [get_state_history](#get-state-history) ( entity_ids: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html), start: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), _end: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) = `null` )                                                                                                 |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [get_todo_items](#get-todo-items) ( entity_id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                                                                                                                                                                                                      |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [get_voice_assistant](#get-voice-assistant) (  )                                                                                                                                                                                                                                                                                                                                                                 |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [has_connected](#has-connected) (  )                                                                                                                                                                                                                                                                                                                                                                             |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [has_integration](#has-integration) (  )                                                                                                                                                                                                                                                                                                                                                                         |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [set_state](#set-state) ( entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), attributes: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) = `{}` )                                                                                                       |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [unwatch_owner](#unwatch-owner) ( target: [Object](https://docs.godotengine.org/en/stable/classes/class_object.html) )                                                                                                                                                                                                                                                                                           |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [update_entity](#update-entity) ( entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), attributes: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) = `{}`, merge: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) = `true` )       |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [update_room](#update-room) ( _room: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                                                                                                                                                                                                                |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [watch_state](#watch-state) ( entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), callback: [Callable](https://docs.godotengine.org/en/stable/classes/class_callable.html) )                                                                                                                                                                                                     |

## Signals

### on_call (entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , attributes: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)  ) {#on-call}

No description provided yet.

### on_connect ( ) {#on-connect}

No description provided yet.

### on_disconnect ( ) {#on-disconnect}

No description provided yet.

## Property Descriptions

### _cover_moves: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#prop--cover-moves}

Increases on every cover command, so a running movement notices it was replaced.

### calls: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) {#prop-calls}

Every service call an entity made, newest last: {entity, state, attributes}.

### devices: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) {#prop-devices}

Devices in the shape of the Home Assistant adapter's get_devices() (see hass_ws/templates/devices.j2): [{id, name, area, manufacturer, model, entities: [{id, name}]}]

### entities: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#prop-entities}

No description provided yet.

### entity_callbacks: [CallbackMap](/reference/CallbackMap.html) {#prop-entity-callbacks}

No description provided yet.

## Method Descriptions

### static _format_duration (seconds: [float](https://docs.godotengine.org/en/stable/classes/class_float.html)  ) -> [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#-format-duration}

No description provided yet.

### _init (initial_states: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) = `{}`  ) -> void {#-init}

No description provided yet.

### _install_update (entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-install-update}

No description provided yet.

### _move_cover (entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , move_id: [int](https://docs.godotengine.org/en/stable/classes/class_int.html) , target: [int](https://docs.godotengine.org/en/stable/classes/class_int.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-move-cover}

No description provided yet.

### _normalize (state: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)  ) -> [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#-normalize}

No description provided yet.

### static _parse_duration (text: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)  ) -> [int](https://docs.godotengine.org/en/stable/classes/class_int.html) {#-parse-duration}

No description provided yet.

### _simulate_alarm (entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) , state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , service_data: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-simulate-alarm}

Arming takes a moment ("arming"), disarming is immediate. A code_format panel checks the code against "_code".

### _simulate_climate (current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) , state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , service_data: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-simulate-climate}

No description provided yet.

### _simulate_cover (entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) , state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , service_data: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-simulate-cover}

Covers move 10 % every 0.3 s and report opening/closing meanwhile. Covers without current_position switch after a second.

### _simulate_fan (current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) , state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , service_data: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-simulate-fan}

No description provided yet.

### _simulate_humidifier (current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) , state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , service_data: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-simulate-humidifier}

No description provided yet.

### _simulate_light (current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) , state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , service_data: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-simulate-light}

No description provided yet.

### _simulate_lock (entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) , state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-simulate-lock}

Locks report "locking"/"unlocking" first and settle a moment later, like real ones.

### _simulate_media_player (current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) , state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , service_data: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-simulate-media-player}

No description provided yet.

### _simulate_timer (current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) , state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-simulate-timer}

No description provided yet.

### _simulate_update (entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) , state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-simulate-update}

Installs in 10 % steps, then reports the latest version as installed.

### _simulate_vacuum (entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) , state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , service_data: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-simulate-vacuum}

No description provided yet.

### _simulate_water_heater (current: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) , state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , service_data: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-simulate-water-heater}

No description provided yet.

### get_device (_id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#get-device}

No description provided yet.

### get_devices ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#get-devices}

No description provided yet.

### get_entity_ids (domains: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)  ) -> [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) {#get-entity-ids}

No description provided yet.

### get_history (entity_id: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , start: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , interval: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , _end: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) = `null`  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#get-history}

Fake hourly statistics: a smooth curve around the entity's current value.

### get_http_url ( ) -> [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#get-http-url}

No description provided yet.

### get_state (entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#get-state}

No description provided yet.

### get_state_history (entity_ids: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) , start: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , _end: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) = `null`  ) -> [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#get-state-history}

Made-up position history: every 10 minutes along a wandering route from the home zone to the current position (the same route every time for an entity).

### get_todo_items (entity_id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#get-todo-items}

To-do items are kept in the entity's "_items" attribute.

### get_voice_assistant ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#get-voice-assistant}

No description provided yet.

### has_connected ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#has-connected}

No description provided yet.

### has_integration ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#has-integration}

No description provided yet.

### set_state (entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , attributes: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) = `{}`  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#set-state}

No description provided yet.

### unwatch_owner (target: [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#unwatch-owner}

No description provided yet.

### update_entity (entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , attributes: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) = `{}` , merge: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) = `true`  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#update-entity}

Replaces the state of `entity` like a Home Assistant state_changed event would.

### update_room (_room: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#update-room}

No description provided yet.

### watch_state (entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , callback: [Callable](https://docs.godotengine.org/en/stable/classes/class_callable.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#watch-state}

No description provided yet.
