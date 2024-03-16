# EventKey
**Inherits:** [EventWithModifiers](/reference/EventWithModifiers.html)
    
## Description

Events emitted by the Virtual Keyboard

## Properties

| Name               | Type                                                                | Default |
| ------------------ | ------------------------------------------------------------------- | ------- |
| [echo](#prop-echo) | [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html) |         |
| [key](#prop-key)   | [int](https://docs.godotengine.org/de/4.x/classes/class_int.html)   |         |

## Methods

| Returns                                                                 | Name                                                                                                                                                                                                                                                                     |
| ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) | [key_to_string](#key-to-string) ( key: [int](https://docs.godotengine.org/de/4.x/classes/class_int.html), caps: [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html), apply_to: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) ) |







## Property Descriptions

### echo: [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html) {#prop-echo}

true if the event is repeated due to a key being held down for a while

### key: [int](https://docs.godotengine.org/de/4.x/classes/class_int.html) {#prop-key}

The key that was pressed or released

## Method Descriptions

### static key_to_string (key: [int](https://docs.godotengine.org/de/4.x/classes/class_int.html) , caps: [bool](https://docs.godotengine.org/de/4.x/classes/class_bool.html) , apply_to: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html)  ) -> [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) {#key-to-string}

Modifies a string based on the key pressed
