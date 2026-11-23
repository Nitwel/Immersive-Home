# HomeApi
**Inherits:** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

## Description

Manages the connection to the home automation system and provides a unified interface to the different home automation systems.

## Properties

| Name                                           | Type                                                                         | Default |
| ---------------------------------------------- | ---------------------------------------------------------------------------- | ------- |
| [_synced_floor_plan](#prop--synced-floor-plan) | [String](https://docs.godotengine.org/en/stable/classes/class_string.html)   | `""`    |
| [api](#prop-api)                               | [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)       |         |
| [api_type](#prop-api-type)                     | [String](https://docs.godotengine.org/en/stable/classes/class_string.html)   | `""`    |
| [floor_plan_timer](#prop-floor-plan-timer)     | [Timer](https://docs.godotengine.org/en/stable/classes/class_timer.html)     |         |
| [groups](#prop-groups)                         | [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) |         |
| [reconnect_timer](#prop-reconnect-timer)       | [Timer](https://docs.godotengine.org/en/stable/classes/class_timer.html)     |         |

## Methods

| Returns                                                                            | Name                                                                                                                                                                                                                                                                                                                                                                                             |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_build_demo_house](#-build-demo-house) (  )                                                                                                                                                                                                                                                                                                                                                     |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_on_connect](#-on-connect) (  )                                                                                                                                                                                                                                                                                                                                                                 |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_on_disconnect](#-on-disconnect) (  )                                                                                                                                                                                                                                                                                                                                                           |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_on_integration_ready](#-on-integration-ready) (  )                                                                                                                                                                                                                                                                                                                                             |
| void                                                                               | [_ready](#-ready) (  )                                                                                                                                                                                                                                                                                                                                                                           |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [_use_house_of](#-use-house-of) ( type: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                                                                                                                                                                                             |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [get_device](#get-device) ( id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                                                                                                                                                                                                     |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [get_devices](#get-devices) (  )                                                                                                                                                                                                                                                                                                                                                                 |
| [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)           | [get_entity_ids](#get-entity-ids) ( domains: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) )                                                                                                                                                                                                                                                                          |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [get_history](#get-history) ( entity_id: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), start: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), interval: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), end: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) = `null` ) |
| [String](https://docs.godotengine.org/en/stable/classes/class_string.html)         | [get_http_url](#get-http-url) (  )                                                                                                                                                                                                                                                                                                                                                               |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [get_state](#get-state) ( entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                                                                                                                                                                                                   |
| [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | [get_state_history](#get-state-history) ( entity_ids: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html), start: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), end: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) = `null` )                                                                                  |
| [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)           | [get_todo_items](#get-todo-items) ( entity_id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                                                                                                                                                                                      |
| [VoiceHandler](/reference/lib--home_apis--voice_handler.html)                      | [get_voice_assistant](#get-voice-assistant) (  )                                                                                                                                                                                                                                                                                                                                                 |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [has_connected](#has-connected) (  )                                                                                                                                                                                                                                                                                                                                                             |
| [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)             | [has_integration](#has-integration) (  )                                                                                                                                                                                                                                                                                                                                                         |
| [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)             | [is_demo](#is-demo) (  )                                                                                                                                                                                                                                                                                                                                                                         |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [set_state](#set-state) ( entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), attributes: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) = `{}` )                                                                                       |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [start](#start) (  )                                                                                                                                                                                                                                                                                                                                                                             |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [start_adapter](#start-adapter) ( type: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), url: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), token: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                         |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [start_demo](#start-demo) (  )                                                                                                                                                                                                                                                                                                                                                                   |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [stop_demo](#stop-demo) (  )                                                                                                                                                                                                                                                                                                                                                                     |
| void                                                                               | [sync_floor_plan](#sync-floor-plan) (  )                                                                                                                                                                                                                                                                                                                                                         |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [unwatch_owner](#unwatch-owner) ( target: [Object](https://docs.godotengine.org/en/stable/classes/class_object.html) )                                                                                                                                                                                                                                                                           |
| void                                                                               | [update_room](#update-room) ( room: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                                                                                                                                                                                                 |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [watch_state](#watch-state) ( entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), callback: [Callable](https://docs.godotengine.org/en/stable/classes/class_callable.html) )                                                                                                                                                                                     |

## Signals

### on_connect ( ) {#on-connect}

Emitted when the connection to the home automation system is established

### on_disconnect ( ) {#on-disconnect}

Emitted when the connection to the home automation system is lost

## Constants

### Demo = `<Object>` {#const-Demo}

No description provided yet.

### DemoHouse = `<Object>` {#const-DemoHouse}

No description provided yet.

### EntityGroups = `<Object>` {#const-EntityGroups}

No description provided yet.

### FLOOR_PLAN_SYNC_DELAY = `2.0` {#const-FLOOR-PLAN-SYNC-DELAY}

Seconds to wait after the house changed before syncing the floor plan, moving things around saves the house many times in a row.

### FloorPlan = `<Object>` {#const-FloorPlan}

No description provided yet.

### HassWebSocket = `<Object>` {#const-HassWebSocket}

No description provided yet.

### HouseStore = `<Object>` {#const-HouseStore}

No description provided yet.

### VoiceAssistant = `<Object>` {#const-VoiceAssistant}

No description provided yet.

### apis = `{"demo": <Object>, "hass_ws": <Object>}` {#const-apis}

No description provided yet.

## Property Descriptions

### _synced_floor_plan: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#prop--synced-floor-plan}

JSON of the floor plan Home Assistant last stored, to skip unchanged syncs

### api: [Node](https://docs.godotengine.org/en/stable/classes/class_node.html) {#prop-api}

The current home automation system adapter

### api_type: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#prop-api-type}

Type of the current adapter, a key of `apis`

### floor_plan_timer: [Timer](https://docs.godotengine.org/en/stable/classes/class_timer.html) {#prop-floor-plan-timer}

No description provided yet.

### groups: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#prop-groups}

No description provided yet.

### reconnect_timer: [Timer](https://docs.godotengine.org/en/stable/classes/class_timer.html) {#prop-reconnect-timer}

No description provided yet.

## Method Descriptions

### _build_demo_house ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-build-demo-house}

Saves the demo apartment, built around where the user is standing.

### _on_connect ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-on-connect}

No description provided yet.

### _on_disconnect ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-on-disconnect}

No description provided yet.

### _on_integration_ready ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-on-integration-ready}

A fresh connection: push the floor plan even if it didn't change, Home Assistant may have lost it or another headset may have replaced it in the meantime.

### _ready ( ) -> void {#-ready}

No description provided yet.

### _use_house_of (type: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-use-house-of}

The demo mode keeps its own house, so it never changes the real one.

### get_device (id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#get-device}

Get a single device by id

### get_devices ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#get-devices}

Get a list of all devices

### get_entity_ids (domains: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)  ) -> [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) {#get-entity-ids}

Ids of all entities in `domains`, e.g. ["person", "device_tracker"].

### get_history (entity_id: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , start: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , interval: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , end: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) = `null`  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#get-history}

No description provided yet.

### get_http_url ( ) -> [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#get-http-url}

Returns the HTTP(S) base URL of the home automation server, without a trailing slash, or an empty string if the adapter does not expose one.

### get_state (entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#get-state}

Returns the current state of an entity

### get_state_history (entity_ids: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) , start: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , end: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) = `null`  ) -> [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#get-state-history}

Recorded states with attributes of several entities since `start` (ISO time): {entity_id: [{state, attributes, time}]}, oldest first. Empty if the adapter has no history.

### get_todo_items (entity_id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) {#get-todo-items}

Returns the items of a to-do list entity: [{uid, summary, status, due?}], or an empty array if the adapter can't list them.

### get_voice_assistant ( ) -> [VoiceHandler](/reference/lib--home_apis--voice_handler.html) {#get-voice-assistant}

Returns the VoiceHandler if the adapter has a voice assistant

### has_connected ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#has-connected}

Returns true if the adapter is connected to the home automation system

### has_integration ( ) -> [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#has-integration}

Returns true if the adapter has an integration in the home automation system allowing to send the room position of the headset.

### is_demo ( ) -> [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#is-demo}

Returns true while the demo mode runs, with made-up devices instead of a real home automation system.

### set_state (entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , attributes: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) = `{}`  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#set-state}

Updates the state of the entity and returns the resulting state

### start ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#start}

Starts the adapter with the settings from the settings file

### start_adapter (type: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , url: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , token: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#start-adapter}

Starts the adapter for the given type and url

### start_demo ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#start-demo}

Starts the demo mode with a freshly built demo apartment around the user. It's remembered, so the app starts in demo mode until [`stop_demo()`](#stop-demo) is called.

### stop_demo ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#stop-demo}

Leaves the demo mode and connects to the home automation system in the settings.

### sync_floor_plan ( ) -> void {#sync-floor-plan}

Sends the floor plan of the house (rooms, doors and the placed entities) to the home automation system, if it has an integration that stores it. Does nothing if the floor plan didn't change since the last sync.

### unwatch_owner (target: [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#unwatch-owner}

Stops every state watch whose callback belongs to `target`. Entities call this when they are freed, so Home Assistant updates never reach a freed node.

### update_room (room: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> void {#update-room}

Updates the room position of the headset in the home automation system

### watch_state (entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , callback: [Callable](https://docs.godotengine.org/en/stable/classes/class_callable.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#watch-state}

Watches the state and each time it changes, calls the callback with the changed state, returns a function to stop watching the state
