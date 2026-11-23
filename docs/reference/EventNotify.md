# EventNotify
**Inherits:** [Event](/reference/Event.html)

## Description

Emits a message to the user

## Properties

| Name                     | Type                                                                       | Default |
| ------------------------ | -------------------------------------------------------------------------- | ------- |
| [message](#prop-message) | [String](https://docs.godotengine.org/en/stable/classes/class_string.html) |         |
| [type](#prop-type)       | [EventNotify.Type](/reference/EventNotify.html#enum-Type)                  |         |

## Enums

### enum Type {#enum-Type}

#### Type.INFO = `0` {#const-INFO}

The message is informational

#### Type.SUCCESS = `1` {#const-SUCCESS}

The message is a success message

#### Type.WARNING = `2` {#const-WARNING}

The message is a warning

#### Type.DANGER = `3` {#const-DANGER}

The message is an error

## Property Descriptions

### message: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#prop-message}

The message to emit

### type: [EventNotify.Type](/reference/EventNotify.html#enum-Type) {#prop-type}

The type of message to emit
