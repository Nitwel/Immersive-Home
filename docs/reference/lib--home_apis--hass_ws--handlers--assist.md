# Assist
**Inherits:** [VoiceHandler](/reference/lib--home_apis--voice_handler.html)

## Properties

| Name                                     | Type                                                                                         | Default             |
| ---------------------------------------- | -------------------------------------------------------------------------------------------- | ------------------- |
| [api](#prop-api)                         | [Hass](/reference/lib--home_apis--hass_ws--hass.html)                                        |                     |
| [handler_id](#prop-handler-id)           | [int](https://docs.godotengine.org/en/stable/classes/class_int.html)                         | `0`                 |
| [pending_audio](#prop-pending-audio)     | [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html) | `PackedByteArray()` |
| [pipe_running](#prop-pipe-running)       | [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)                       | `false`             |
| [pipe_start_time](#prop-pipe-start-time) | [int](https://docs.godotengine.org/en/stable/classes/class_int.html)                         | `0`                 |
| [pipe_starting](#prop-pipe-starting)     | [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)                       | `false`             |
| [stt_message](#prop-stt-message)         | [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                 | `null`              |
| [tts_message](#prop-tts-message)         | [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                 | `null`              |
| [tts_sound](#prop-tts-sound)             | [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                 | `null`              |
| [wake_word](#prop-wake-word)             | [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                 | `null`              |

## Methods

| Returns                                                                      | Name                                                                                                                               |
| ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| void                                                                         | [_init](#-init) ( hass: [Hass](/reference/lib--home_apis--hass_ws--hass.html) )                                                    |
| void                                                                         | [_send_audio](#-send-audio) ( data: [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html) ) |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) | [handle_message](#handle-message) ( message: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) )  |
| void                                                                         | [send_data](#send-data) ( data: [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html) )     |
| [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)       | [start_wakeword](#start-wakeword) (  )                                                                                             |

## Constants

### HASS_API = `<Object>` {#const-HASS-API}

No description provided yet.

### MAX_PENDING_BYTES = `160000` {#const-MAX-PENDING-BYTES}

Max audio kept while waiting for the pipeline to start: 5 s of 16 kHz 16 bit mono.

### START_TIMEOUT_MS = `10000` {#const-START-TIMEOUT-MS}

How long to wait for run-start before allowing a new pipeline request.

### VoiceHandler = `<Object>` {#const-VoiceHandler}

No description provided yet.

## Property Descriptions

### api: [Hass](/reference/lib--home_apis--hass_ws--hass.html) {#prop-api}

No description provided yet.

### handler_id: [int](https://docs.godotengine.org/en/stable/classes/class_int.html) {#prop-handler-id}

No description provided yet.

### pending_audio: [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html) {#prop-pending-audio}

Audio captured while the pipeline was starting, sent once it is running.

### pipe_running: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#prop-pipe-running}

No description provided yet.

### pipe_start_time: [int](https://docs.godotengine.org/en/stable/classes/class_int.html) {#prop-pipe-start-time}

No description provided yet.

### pipe_starting: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#prop-pipe-starting}

True between requesting a pipeline run and receiving its run-start event.

### stt_message: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#prop-stt-message}

No description provided yet.

### tts_message: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#prop-tts-message}

No description provided yet.

### tts_sound: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#prop-tts-sound}

No description provided yet.

### wake_word: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#prop-wake-word}

No description provided yet.

## Method Descriptions

### _init (hass: [Hass](/reference/lib--home_apis--hass_ws--hass.html)  ) -> void {#-init}

No description provided yet.

### _send_audio (data: [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html)  ) -> void {#-send-audio}

Sends audio to the running pipeline, prefixed with the handler id in 8 bits. An empty array tells Home Assistant the audio stream has ended.

### handle_message (message: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#handle-message}

No description provided yet.

### send_data (data: [PackedByteArray](https://docs.godotengine.org/en/stable/classes/class_packedbytearray.html)  ) -> void {#send-data}

No description provided yet.

### start_wakeword ( ) -> [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#start-wakeword}

No description provided yet.
