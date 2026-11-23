# SetupCode
**Inherits:** [RefCounted](https://docs.godotengine.org/en/stable/classes/class_refcounted.html)

## Description

Reads Home Assistant connection settings from a scanned QR code.

Supported contents: - A long-lived access token on its own - The address of the instance, e.g. `http://homeassistant.local:8123` or `192.168.0.10:8123`. An `access_token` or `token` query parameter is used as token. - JSON, e.g. `{"url": "http://homeassistant.local:8123", "token": "..."}`

## Methods

| Returns                                                                            | Name                                                                                                                          |
| ---------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)             | [is_token](#is-token) ( text: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                    |
| [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | [parse](#parse) ( text: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                          |
| [String](https://docs.godotengine.org/en/stable/classes/class_string.html)         | [to_websocket_url](#to-websocket-url) ( address: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) ) |

## Constants

### DEFAULT_PORT = `8123` {#const-DEFAULT-PORT}

No description provided yet.

## Method Descriptions

### static is_token (text: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#is-token}

Returns true if `text` looks like a Home Assistant access token (a JWT).

### static parse (text: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#parse}

Returns `{"url": String, "token": String}`. Values that weren't found are empty. `url` is a websocket URL as expected by the hass_ws adapter.

### static to_websocket_url (address: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#to-websocket-url}

Turns an address of a Home Assistant instance into the websocket URL of its API, without a path. Returns an empty string if `address` isn't an address.
