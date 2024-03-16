# Hass
**Inherits:** [Node](https://docs.godotengine.org/de/4.x/classes/class_node.html)
    


## Properties

| Name                                        | Type                                                                                  | Default |
| ------------------------------------------- | ------------------------------------------------------------------------------------- | ------- |
| [LOG_MESSAGES](#LOG-MESSAGES)               | [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html)                   | `false` |
| [assist_handler](#assist-handler)           | [Assist](/reference/lib--home_apis--hass_ws--handlers--assist.html)                   |         |
| [auth_handler](#auth-handler)               | [Auth](/reference/lib--home_apis--hass_ws--handlers--auth.html)                       |         |
| [connected](#connected)                     | [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html)                   | `false` |
| [devices_template](#devices-template)       | [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)               |         |
| [entities](#entities)                       | [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html)       |         |
| [entitiy_callbacks](#entitiy-callbacks)     | [CallbackMap](/reference/CallbackMap.html)                                            |         |
| [id](#id)                                   | [int](https://docs.godotengine.org/de/4.x/classes/class_int.html)                     | `1`     |
| [integration_handler](#integration-handler) | [Integration](/reference/lib--home_apis--hass_ws--handlers--integration.html)         |         |
| [packet_callbacks](#packet-callbacks)       | [CallbackMap](/reference/CallbackMap.html)                                            |         |
| [request_timeout](#request-timeout)         | [float](https://docs.godotengine.org/de/4.x/classes/class_float.html)                 | `10.0`  |
| [socket](#socket)                           | [WebSocketPeer](https://docs.godotengine.org/de/4.x/classes/class_websocketpeer.html) |         |
| [token](#token)                             | [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)               | `""`    |
| [url](#url)                                 | [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)               | `""`    |

## Methods

| Returns                                                                   | Name                                                                                                                                                                                                                                                                                       |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| void                                                                      | [_init](#-init) ( url: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), token: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) )                                                                                                           |
| void                                                                      | [_process](#-process) ( delta: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) )                                                                                                                                                                                 |
| void                                                                      | [connect_ws](#connect-ws) (  )                                                                                                                                                                                                                                                             |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [decode_packet](#decode-packet) ( packet: [PackedByteArray](https://docs.godotengine.org/de/4.x/classes/class_packedbytearray.html) )                                                                                                                                                      |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [encode_packet](#encode-packet) ( packet: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html) )                                                                                                                                                                |
| void                                                                      | [get_device](#get-device) ( id: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) )                                                                                                                                                                                  |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [get_devices](#get-devices) (  )                                                                                                                                                                                                                                                           |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [get_state](#get-state) ( entity: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) )                                                                                                                                                                                |
| void                                                                      | [handle_connect](#handle-connect) (  )                                                                                                                                                                                                                                                     |
| void                                                                      | [handle_disconnect](#handle-disconnect) (  )                                                                                                                                                                                                                                               |
| void                                                                      | [handle_packet](#handle-packet) ( packet: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html) )                                                                                                                                                                |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [has_connected](#has-connected) (  )                                                                                                                                                                                                                                                       |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [has_integration](#has-integration) (  )                                                                                                                                                                                                                                                   |
| void                                                                      | [send_packet](#send-packet) ( packet: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html), with_id: [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html) )                                                                                      |
| void                                                                      | [send_raw](#send-raw) ( packet: [PackedByteArray](https://docs.godotengine.org/de/4.x/classes/class_packedbytearray.html) )                                                                                                                                                                |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [send_request_packet](#send-request-packet) ( packet: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html), ignore_initial: [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html) )                                                               |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [send_subscribe_packet](#send-subscribe-packet) ( packet: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html), callback: [Callable](https://docs.godotengine.org/de/4.x/classes/class_callable.html) )                                                         |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [set_state](#set-state) ( entity: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), state: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html), attributes: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html) ) |
| void                                                                      | [start_subscriptions](#start-subscriptions) (  )                                                                                                                                                                                                                                           |
| void                                                                      | [update_room](#update-room) ( room: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) )                                                                                                                                                                              |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [watch_state](#watch-state) ( entity: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), callback: [Callable](https://docs.godotengine.org/de/4.x/classes/class_callable.html) )                                                                                     |

## Signals

### on_connect ( ) {#on-connect}

No description provided yet.

### on_disconnect ( ) {#on-disconnect}

No description provided yet.

## Constants


### AuthHandler = `<Object>` {#const-AuthHandler}

No description provided yet.
                


### IntegrationHandler = `<Object>` {#const-IntegrationHandler}

No description provided yet.
                


### AssistHandler = `<Object>` {#const-AssistHandler}

No description provided yet.
                

## Property Descriptions

### LOG_MESSAGES: [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html) {#LOG-MESSAGES}

No description provided yet.

### assist_handler: [Assist](/reference/lib--home_apis--hass_ws--handlers--assist.html) {#assist-handler}

No description provided yet.

### auth_handler: [Auth](/reference/lib--home_apis--hass_ws--handlers--auth.html) {#auth-handler}

No description provided yet.

### connected: [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html) {#connected}

No description provided yet.

### devices_template: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) {#devices-template}

No description provided yet.

### entities: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html) {#entities}

No description provided yet.

### entitiy_callbacks: [CallbackMap](/reference/CallbackMap.html) {#entitiy-callbacks}

No description provided yet.

### id: [int](https://docs.godotengine.org/de/4.x/classes/class_int.html) {#id}

No description provided yet.

### integration_handler: [Integration](/reference/lib--home_apis--hass_ws--handlers--integration.html) {#integration-handler}

No description provided yet.

### packet_callbacks: [CallbackMap](/reference/CallbackMap.html) {#packet-callbacks}

No description provided yet.

### request_timeout: [float](https://docs.godotengine.org/de/4.x/classes/class_float.html) {#request-timeout}

No description provided yet.

### socket: [WebSocketPeer](https://docs.godotengine.org/de/4.x/classes/class_websocketpeer.html) {#socket}

No description provided yet.

### token: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) {#token}

No description provided yet.

### url: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) {#url}

No description provided yet.

## Method Descriptions

### _init (url: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , token: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)  ) -> void {#-init}

No description provided yet.

### _process (delta: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html)  ) -> void {#-process}

No description provided yet.

### connect_ws ( ) -> void {#connect-ws}

No description provided yet.

### decode_packet (packet: [PackedByteArray](https://docs.godotengine.org/de/4.x/classes/class_packedbytearray.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#decode-packet}

No description provided yet.

### encode_packet (packet: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#encode-packet}

No description provided yet.

### get_device (id: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)  ) -> void {#get-device}

No description provided yet.

### get_devices ( ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#get-devices}

No description provided yet.

### get_state (entity: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#get-state}

No description provided yet.

### handle_connect ( ) -> void {#handle-connect}

No description provided yet.

### handle_disconnect ( ) -> void {#handle-disconnect}

No description provided yet.

### handle_packet (packet: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html)  ) -> void {#handle-packet}

No description provided yet.

### has_connected ( ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#has-connected}

No description provided yet.

### has_integration ( ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#has-integration}

No description provided yet.

### send_packet (packet: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html) , with_id: [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html)  ) -> void {#send-packet}

No description provided yet.

### send_raw (packet: [PackedByteArray](https://docs.godotengine.org/de/4.x/classes/class_packedbytearray.html)  ) -> void {#send-raw}

No description provided yet.

### send_request_packet (packet: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html) , ignore_initial: [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#send-request-packet}

No description provided yet.

### send_subscribe_packet (packet: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html) , callback: [Callable](https://docs.godotengine.org/de/4.x/classes/class_callable.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#send-subscribe-packet}

No description provided yet.

### set_state (entity: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , state: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) , attributes: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#set-state}

No description provided yet.

### start_subscriptions ( ) -> void {#start-subscriptions}

No description provided yet.

### update_room (room: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)  ) -> void {#update-room}

No description provided yet.

### watch_state (entity: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , callback: [Callable](https://docs.godotengine.org/de/4.x/classes/class_callable.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#watch-state}

No description provided yet.
