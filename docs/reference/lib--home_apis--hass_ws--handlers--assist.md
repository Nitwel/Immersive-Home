# Assist
**Inherits:** [RefCounted](https://docs.godotengine.org/de/4.x/classes/class_refcounted.html)
    


## Properties

| Name                               | Type                                                                      | Default |
| ---------------------------------- | ------------------------------------------------------------------------- | ------- |
| [api](#prop-api)                   | [Hass](/reference/lib--home_apis--hass_ws--hass.html)                     |         |
| [handler_id](#prop-handler-id)     | [int](https://docs.godotengine.org/de/4.x/classes/class_int.html)         | `0`     |
| [pipe_running](#prop-pipe-running) | [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html)       | `false` |
| [stt_message](#prop-stt-message)   | [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | `null`  |
| [tts_message](#prop-tts-message)   | [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | `null`  |
| [tts_sound](#prop-tts-sound)       | [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | `null`  |
| [wake_word](#prop-wake-word)       | [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | `null`  |

## Methods

| Returns | Name                                                                                                                           |
| ------- | ------------------------------------------------------------------------------------------------------------------------------ |
| void    | [_init](#-init) ( hass: [Hass](/reference/lib--home_apis--hass_ws--hass.html) )                                                |
| void    | [handle_message](#handle-message) ( message: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html) ) |
| void    | [on_connect](#on-connect) (  )                                                                                                 |
| void    | [send_data](#send-data) ( data: [PackedByteArray](https://docs.godotengine.org/de/4.x/classes/class_packedbytearray.html) )    |
| void    | [start_wakeword](#start-wakeword) (  )                                                                                         |

## Signals

### on_error ( ) {#on-error}

No description provided yet.

### on_stt_message (message: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)  ) {#on-stt-message}

No description provided yet.

### on_tts_message (message: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)  ) {#on-tts-message}

No description provided yet.

### on_tts_sound (sound: [AudioStreamMP3](https://docs.godotengine.org/de/4.x/classes/class_audiostreammp3.html)  ) {#on-tts-sound}

No description provided yet.

### on_wake_word (wake_word: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)  ) {#on-wake-word}

No description provided yet.



## Constants

### HASS_API = `<Object>` {#const-HASS-API}

No description provided yet.

## Property Descriptions

### api: [Hass](/reference/lib--home_apis--hass_ws--hass.html) {#prop-api}

No description provided yet.

### handler_id: [int](https://docs.godotengine.org/de/4.x/classes/class_int.html) {#prop-handler-id}

No description provided yet.

### pipe_running: [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html) {#prop-pipe-running}

No description provided yet.

### stt_message: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#prop-stt-message}

No description provided yet.

### tts_message: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#prop-tts-message}

No description provided yet.

### tts_sound: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#prop-tts-sound}

No description provided yet.

### wake_word: [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#prop-wake-word}

No description provided yet.

## Method Descriptions

###  _init (hass: [Hass](/reference/lib--home_apis--hass_ws--hass.html)  ) -> void {#-init}

No description provided yet.

###  handle_message (message: [Dictionary](https://docs.godotengine.org/de/4.x/classes/class_dictionary.html)  ) -> void {#handle-message}

No description provided yet.

###  on_connect ( ) -> void {#on-connect}

No description provided yet.

###  send_data (data: [PackedByteArray](https://docs.godotengine.org/de/4.x/classes/class_packedbytearray.html)  ) -> void {#send-data}

No description provided yet.

###  start_wakeword ( ) -> void {#start-wakeword}

No description provided yet.
