# HomeApi
**Inherits:** [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html)
    


## Properties

| Name        | Type                                                                | Default |
| ----------- | ------------------------------------------------------------------- | ------- |
| [api](#api) | [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html) |         |

## Methods

| Returns                                                                   | Name                                                                                                                                                                                                                                                                                       |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| void                                                                      | [_notification](#-notification) ( what: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) )                                                                                                                                                                        |
| void                                                                      | [_on_connect](#-on-connect) (  )                                                                                                                                                                                                                                                           |
| void                                                                      | [_on_disconnect](#-on-disconnect) (  )                                                                                                                                                                                                                                                     |
| void                                                                      | [_ready](#-ready) (  )                                                                                                                                                                                                                                                                     |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [get_device](#get-device) ( id: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) )                                                                                                                                                                                  |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [get_devices](#get-devices) (  )                                                                                                                                                                                                                                                           |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [get_state](#get-state) ( entity: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) )                                                                                                                                                                                |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [has_connected](#has-connected) (  )                                                                                                                                                                                                                                                       |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [set_state](#set-state) ( entity: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), state: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html), attributes: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html) ) |
| void                                                                      | [start_adapter](#start-adapter) ( type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), url: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), token: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) )            |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [watch_state](#watch-state) ( entity: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), callback: [Callable](https://docs.godotengine.org/de/4.x/classes/class_callable.html) )                                                                                     |

## Signals

### on_connect ( ) {#on-connect}

No description provided yet.

### on_disconnect ( ) {#on-disconnect}

No description provided yet.

## Constants


### Hass = `<Object>` {#const-Hass}

No description provided yet.
                


### HassWebSocket = `<Object>` {#const-HassWebSocket}

No description provided yet.
                


### apis = `{"hass": <Object>, "hass_ws": <Object>}` {#const-apis}

No description provided yet.
                


### methods = `["get_devices", "get_device", "get_state", "set_state", "watch_state"]` {#const-methods}

No description provided yet.
                

## Property Descriptions

### api: [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html) {#api}

No description provided yet.

## Method Descriptions

### _notification (what: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html)  ) -> void {#-notification}

No description provided yet.

### _on_connect ( ) -> void {#-on-connect}

No description provided yet.

### _on_disconnect ( ) -> void {#-on-disconnect}

No description provided yet.

### _ready ( ) -> void {#-ready}

No description provided yet.

### get_device (id: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#get-device}

Get a single device by id

### get_devices ( ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#get-devices}

Get a list of all devices

### get_state (entity: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#get-state}

Returns the current state of an entity

### has_connected ( ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#has-connected}

No description provided yet.

### set_state (entity: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , state: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) , attributes: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#set-state}

Updates the state of the entity and returns the resulting state

### start_adapter (type: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , url: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , token: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)  ) -> void {#start-adapter}

No description provided yet.

### watch_state (entity: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , callback: [Callable](https://docs.godotengine.org/de/4.x/classes/class_callable.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#watch-state}

Watches the state and each time it changes, calls the callback with the changed state, returns a function to stop watching the state
