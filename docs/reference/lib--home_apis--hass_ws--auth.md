# Auth
**Inherits:** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

## Properties

| Name                                 | Type                                                                       | Default |
| ------------------------------------ | -------------------------------------------------------------------------- | ------- |
| [authenticated](#prop-authenticated) | [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)     | `false` |
| [connection](#prop-connection)       | [Connection](/reference/lib--home_apis--hass_ws--connection.html)          |         |
| [token](#prop-token)                 | [String](https://docs.godotengine.org/en/stable/classes/class_string.html) |         |

## Methods

| Returns                                                                        | Name                                                                                                                              |
| ------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)   | [_handle_message](#-handle-message) ( message: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) )     |
| void                                                                           | [_init](#-init) ( connection: [Connection](/reference/lib--home_apis--hass_ws--connection.html) )                                 |
| [Auth.AuthError](/reference/lib--home_apis--hass_ws--auth.html#enum-AuthError) | [authenticate](#authenticate) ( token: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) = `<unknown>` ) |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)   | [on_disconnect](#on-disconnect) (  )                                                                                              |

## Signals

### _try_auth (success: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)  ) {#-try-auth}

No description provided yet.

### on_authenticated ( ) {#on-authenticated}

No description provided yet.

## Enums

### enum AuthError {#enum-AuthError}

#### AuthError.OK = `0` {#const-OK}

No description provided yet.

#### AuthError.INVALID_TOKEN = `1` {#const-INVALID-TOKEN}

No description provided yet.

#### AuthError.TIMEOUT = `2` {#const-TIMEOUT}

No description provided yet.

#### AuthError.UNKNOWN = `3` {#const-UNKNOWN}

No description provided yet.

## Constants

### Connection = `<Object>` {#const-Connection}

No description provided yet.

## Property Descriptions

### authenticated: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#prop-authenticated}

No description provided yet.

### connection: [Connection](/reference/lib--home_apis--hass_ws--connection.html) {#prop-connection}

No description provided yet.

### token: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#prop-token}

No description provided yet.

## Method Descriptions

### _handle_message (message: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-handle-message}

No description provided yet.

### _init (connection: [Connection](/reference/lib--home_apis--hass_ws--connection.html)  ) -> void {#-init}

No description provided yet.

### authenticate (token: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) = `<unknown>`  ) -> [Auth.AuthError](/reference/lib--home_apis--hass_ws--auth.html#enum-AuthError) {#authenticate}

No description provided yet.

### on_disconnect ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#on-disconnect}

No description provided yet.
