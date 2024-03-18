# HomeApi
**Inherits:** [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html)
    
## Description

Manages the connection to the home automation system and provides a unified interface to the different home automation systems.

## Properties

| Name             | Type                                                                | Default |
| ---------------- | ------------------------------------------------------------------- | ------- |
| [api](#prop-api) | [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html) |         |

## Methods

| Returns                                                                   | Name                                                                                                                                                                                                                                                                                       |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| void                                                                      | [_on_connect](#-on-connect) (  )                                                                                                                                                                                                                                                           |
| void                                                                      | [_on_disconnect](#-on-disconnect) (  )                                                                                                                                                                                                                                                     |
| void                                                                      | [_ready](#-ready) (  )                                                                                                                                                                                                                                                                     |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [get_device](#get-device) ( id: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) )                                                                                                                                                                                  |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [get_devices](#get-devices) (  )                                                                                                                                                                                                                                                           |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [get_state](#get-state) ( entity: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) )                                                                                                                                                                                |
| [VoiceHandler](/reference/lib--home_apis--voice_handler.html)             | [get_voice_assistant](#get-voice-assistant) (  )                                                                                                                                                                                                                                           |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [has_connected](#has-connected) (  )                                                                                                                                                                                                                                                       |
| [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html)       | [has_integration](#has-integration) (  )                                                                                                                                                                                                                                                   |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [set_state](#set-state) ( entity: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), state: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html), attributes: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html) ) |
| void                                                                      | [start_adapter](#start-adapter) ( type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), url: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), token: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) )            |
| void                                                                      | [update_room](#update-room) ( room: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) )                                                                                                                                                                              |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [watch_state](#watch-state) ( entity: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), callback: [Callable](https://docs.godotengine.org/de/4.x/classes/class_callable.html) )                                                                                     |

## Signals

### on_connect ( ) {#on-connect}

Emitted when the connection to the home automation system is established

### on_disconnect ( ) {#on-disconnect}

Emitted when the connection to the home automation system is lost



## Constants

### Hass = `<Object>` {#const-Hass}

No description provided yet.

### HassWebSocket = `<Object>` {#const-HassWebSocket}

No description provided yet.

### VoiceAssistant = `<Object>` {#const-VoiceAssistant}

No description provided yet.

### apis = `{"hass": <Object>, "hass_ws": <Object>}` {#const-apis}

No description provided yet.

### methods = `[
  "get_devices",
  "get_device",
  "get_state",
  "set_state",
  "watch_state"
]` {#const-methods}

No description provided yet.

## Property Descriptions

### api: [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html) {#prop-api}

The current home automation system adapter

## Method Descriptions

###  _on_connect ( ) -> void {#-on-connect}

No description provided yet.

###  _on_disconnect ( ) -> void {#-on-disconnect}

No description provided yet.

###  _ready ( ) -> void {#-ready}

No description provided yet.

###  get_device (id: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#get-device}

Get a single device by id

###  get_devices ( ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#get-devices}

Get a list of all devices

###  get_state (entity: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#get-state}

Returns the current state of an entity

###  get_voice_assistant ( ) -> [VoiceHandler](/reference/lib--home_apis--voice_handler.html) {#get-voice-assistant}

Returns the VoiceHandler if the adapter has a voice assistant

###  has_connected ( ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#has-connected}

Returns true if the adapter is connected to the home automation system

###  has_integration ( ) -> [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html) {#has-integration}

Returns true if the adapter has an integration in the home automation system allowing to send the room position of the headset.

###  set_state (entity: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , state: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) , attributes: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#set-state}

Updates the state of the entity and returns the resulting state

###  start_adapter (type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , url: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , token: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)  ) -> void {#start-adapter}

Starts the adapter for the given type and url

###  update_room (room: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)  ) -> void {#update-room}

Updates the room position of the headset in the home automation system

###  watch_state (entity: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , callback: [Callable](https://docs.godotengine.org/de/4.x/classes/class_callable.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#watch-state}

Watches the state and each time it changes, calls the callback with the changed state, returns a function to stop watching the state
