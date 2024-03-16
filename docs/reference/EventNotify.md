# EventNotify
**Inherits:** [Event](/reference/Event.html)
    
## Description

Emits a message to the user

## Properties

| Name                     | Type                                                                    | Default |
| ------------------------ | ----------------------------------------------------------------------- | ------- |
| [message](#prop-message) | [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) |         |
| [type](#prop-type)       | [int](https://docs.godotengine.org/de/4.x/classes/class_int.html)       |         |





## Enums

### enum Type

#### Type.INFO = `0` {#const-INFO}

The message is informational

#### Type.SUCCESS = `1` {#const-SUCCESS}

The message is a success message

#### Type.WARNING = `2` {#const-WARNING}

The message is a warning

#### Type.DANGER = `3` {#const-DANGER}

The message is an error



## Property Descriptions

### message: [String](https://docs.godotengine.org/de/4.x/classes/class_string.html) {#prop-message}

The message to emit

### type: [int](https://docs.godotengine.org/de/4.x/classes/class_int.html) {#prop-type}

The type of message to emit
