# Auth
**Inherits:** [RefCounted](https://docs.godotengine.org/de/4.x/classes/class_refcounted.html)
    


## Properties

| Name                            | Type                                                                    | Default |
| ------------------------------- | ----------------------------------------------------------------------- | ------- |
| [api](#api)                     | [Hass](/reference/lib--home_apis--hass_ws--hass.html)                   |         |
| [authenticated](#authenticated) | [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html)     | `false` |
| [token](#token)                 | [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) |         |
| [url](#url)                     | [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) |         |

## Methods

| Returns | Name                                                                                                                                                                                                                                          |
| ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| void    | [_init](#-init) ( hass: [Hass](/reference/lib--home_apis--hass_ws--hass.html), url: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html), token: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) ) |
| void    | [handle_message](#handle-message) ( message: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) )                                                                                                                      |
| void    | [on_disconnect](#on-disconnect) (  )                                                                                                                                                                                                          |

## Signals

### on_authenticated ( ) {#on-authenticated}

No description provided yet.

## Constants


### HASS_API = `<Object>` {#const-HASS-API}

No description provided yet.
                

## Property Descriptions

### api: [Hass](/reference/lib--home_apis--hass_ws--hass.html) {#api}

No description provided yet.

### authenticated: [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html) {#authenticated}

No description provided yet.

### token: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) {#token}

No description provided yet.

### url: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) {#url}

No description provided yet.

## Method Descriptions

### _init (hass: [Hass](/reference/lib--home_apis--hass_ws--hass.html) , url: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) , token: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)  ) -> void {#-init}

No description provided yet.

### handle_message (message: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html)  ) -> void {#handle-message}

No description provided yet.

### on_disconnect ( ) -> void {#on-disconnect}

No description provided yet.
