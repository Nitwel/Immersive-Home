# Connection
**Inherits:** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

## Properties

| Name                                           | Type                                                                                     | Default |
| ---------------------------------------------- | ---------------------------------------------------------------------------------------- | ------- |
| [api](#prop-api)                               | [Hass](/reference/lib--home_apis--hass_ws--hass.html)                                    |         |
| [auth](#prop-auth)                             | [Auth](/reference/lib--home_apis--hass_ws--auth.html)                                    |         |
| [connected](#prop-connected)                   | [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)                   | `false` |
| [connecting](#prop-connecting)                 | [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)                   | `false` |
| [connection_timeout](#prop-connection-timeout) | [float](https://docs.godotengine.org/en/stable/classes/class_float.html)                 | `10.0`  |
| [id](#prop-id)                                 | [int](https://docs.godotengine.org/en/stable/classes/class_int.html)                     | `1`     |
| [packet_callbacks](#prop-packet-callbacks)     | [CallbackMap](/reference/CallbackMap.html)                                               |         |
| [request_timeout](#prop-request-timeout)       | [float](https://docs.godotengine.org/en/stable/classes/class_float.html)                 | `10.0`  |
| [socket](#prop-socket)                         | [WebSocketPeer](https://docs.godotengine.org/en/stable/classes/class_websocketpeer.html) |         |
| [url](#prop-url)                               | [String](https://docs.godotengine.org/en/stable/classes/class_string.html)               | `""`    |

## Methods

| Returns                                                                                                | Name                                                                                                                                                                                                                                                                                                                                                |
| ------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                           | [_decode_packet](#-decode-packet) ( packet: [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html) )                                                                                                                                                                                                          |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                           | [_encode_packet](#-encode-packet) ( packet: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) )                                                                                                                                                                                                                    |
| void                                                                                                   | [_init](#-init) ( api: [Hass](/reference/lib--home_apis--hass_ws--hass.html) )                                                                                                                                                                                                                                                                      |
| void                                                                                                   | [_process](#-process) ( _delta: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) )                                                                                                                                                                                                                                      |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                           | [handle_packet](#handle-packet) ( packet: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) )                                                                                                                                                                                                                      |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                           | [send_packet](#send-packet) ( packet: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html), with_id: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) = `false` )                                                                                                                               |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                           | [send_raw](#send-raw) ( packet: [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html) )                                                                                                                                                                                                                      |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                           | [send_request_packet](#send-request-packet) ( packet: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html), ignore_initial: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) = `false`, timeout: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) = `request_timeout` ) |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                           | [send_subscribe_packet](#send-subscribe-packet) ( packet: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html), callback: [Callable](https://docs.godotengine.org/en/stable/classes/class_callable.html) )                                                                                                            |
| [Connection.ConnectionError](/reference/lib--home_apis--hass_ws--connection.html#enum-ConnectionError) | [start](#start) ( url: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), token: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                                                                              |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                           | [unsubscribe](#unsubscribe) ( subscription_id: [int](https://docs.godotengine.org/en/stable/classes/class_int.html) )                                                                                                                                                                                                                               |

## Signals

### _try_connect (success: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)  ) {#-try-connect}

No description provided yet.

### on_connect ( ) {#on-connect}

No description provided yet.

### on_disconnect ( ) {#on-disconnect}

No description provided yet.

### on_packed_received (packet: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)  ) {#on-packed-received}

No description provided yet.

## Enums

### enum ConnectionError {#enum-ConnectionError}

#### ConnectionError.OK = `0` {#const-OK}

No description provided yet.

#### ConnectionError.INVALID_URL = `1` {#const-INVALID-URL}

No description provided yet.

#### ConnectionError.CONNECTION_FAILED = `2` {#const-CONNECTION-FAILED}

No description provided yet.

#### ConnectionError.TIMEOUT = `3` {#const-TIMEOUT}

No description provided yet.

#### ConnectionError.INVALID_TOKEN = `4` {#const-INVALID-TOKEN}

No description provided yet.

## Constants

### Auth = `<Object>` {#const-Auth}

No description provided yet.

### HASS_API = `<Object>` {#const-HASS-API}

No description provided yet.

### LOG_RECEIVING = `false` {#const-LOG-RECEIVING}

No description provided yet.

### LOG_SENDING = `false` {#const-LOG-SENDING}

No description provided yet.

## Property Descriptions

### api: [Hass](/reference/lib--home_apis--hass_ws--hass.html) {#prop-api}

No description provided yet.

### auth: [Auth](/reference/lib--home_apis--hass_ws--auth.html) {#prop-auth}

No description provided yet.

### connected: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#prop-connected}

No description provided yet.

### connecting: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#prop-connecting}

No description provided yet.

### connection_timeout: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) {#prop-connection-timeout}

No description provided yet.

### id: [int](https://docs.godotengine.org/en/stable/classes/class_int.html) {#prop-id}

No description provided yet.

### packet_callbacks: [CallbackMap](/reference/CallbackMap.html) {#prop-packet-callbacks}

No description provided yet.

### request_timeout: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) {#prop-request-timeout}

No description provided yet.

### socket: [WebSocketPeer](https://docs.godotengine.org/en/stable/classes/class_websocketpeer.html) {#prop-socket}

No description provided yet.

### url: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#prop-url}

No description provided yet.

## Method Descriptions

### _decode_packet (packet: [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-decode-packet}

No description provided yet.

### _encode_packet (packet: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-encode-packet}

No description provided yet.

### _init (api: [Hass](/reference/lib--home_apis--hass_ws--hass.html)  ) -> void {#-init}

No description provided yet.

### _process (_delta: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)  ) -> void {#-process}

No description provided yet.

### handle_packet (packet: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#handle-packet}

No description provided yet.

### send_packet (packet: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) , with_id: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) = `false`  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#send-packet}

No description provided yet.

### send_raw (packet: [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#send-raw}

No description provided yet.

### send_request_packet (packet: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) , ignore_initial: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) = `false` , timeout: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) = `request_timeout`  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#send-request-packet}

Sends `packet` and waits for its response, settling with the response packet. With `ignore_initial` the request is a subscription: the successful result that confirms it is skipped and the first event is returned. A failed result is returned too, as no event follows it.

### send_subscribe_packet (packet: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) , callback: [Callable](https://docs.godotengine.org/en/stable/classes/class_callable.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#send-subscribe-packet}

No description provided yet.

### start (url: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , token: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Connection.ConnectionError](/reference/lib--home_apis--hass_ws--connection.html#enum-ConnectionError) {#start}

No description provided yet.

### unsubscribe (subscription_id: [int](https://docs.godotengine.org/en/stable/classes/class_int.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#unsubscribe}

Ends a subscription, all Home Assistant subscriptions are ended the same way.
