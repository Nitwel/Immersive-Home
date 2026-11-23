# EventKey
**Inherits:** [EventWithModifiers](/reference/EventWithModifiers.html)

## Description

Events emitted by the Virtual Keyboard

## Properties

| Name               | Type                                                                                               | Default |
| ------------------ | -------------------------------------------------------------------------------------------------- | ------- |
| [echo](#prop-echo) | [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)                             |         |
| [key](#prop-key)   | [Key](https://docs.godotengine.org/en/stable/classes/class_@globalscope.html#enum-globalscope-key) |         |

## Methods

| Returns                                                                    | Name                                                                                                                                                                                                                                                                                                                             |
| -------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [String](https://docs.godotengine.org/en/stable/classes/class_string.html) | [key_to_string](#key-to-string) ( key: [Key](https://docs.godotengine.org/en/stable/classes/class_@globalscope.html#enum-globalscope-key), caps: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) = `false`, apply_to: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) = `""` ) |

## Property Descriptions

### echo: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#prop-echo}

true if the event is repeated due to a key being held down for a while

### key: [Key](https://docs.godotengine.org/en/stable/classes/class_@globalscope.html#enum-globalscope-key) {#prop-key}

The key that was pressed or released

## Method Descriptions

### static key_to_string (key: [Key](https://docs.godotengine.org/en/stable/classes/class_@globalscope.html#enum-globalscope-key) , caps: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) = `false` , apply_to: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) = `""`  ) -> [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#key-to-string}

Modifies a string based on the key pressed. Printable keys use their ASCII keycode (e.g. `KEY_EXCLAM` for "!"), letters are upper case when `caps` is true. Other keys don't produce text.
