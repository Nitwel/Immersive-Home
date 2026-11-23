# EventTouch
**Inherits:** [EventBubble](/reference/EventBubble.html)

## Description

Emitted when a finger enters or leaves a FingerArea.

## Properties

| Name                     | Type                                                                                                                            | Default |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------- | ------- |
| [fingers](#prop-fingers) | [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[Finger](/reference/lib--utils--touch--finger.html)\] | `[]`    |

## Methods

| Returns                                                                      | Name                                                                                                     |
| ---------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) | [has_finger](#has-finger) ( finger: [Finger.Type](/reference/lib--utils--touch--finger.html#enum-Type) ) |

## Constants

### Finger = `<Object>` {#const-Finger}

No description provided yet.

## Property Descriptions

### fingers: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[Finger](/reference/lib--utils--touch--finger.html)\] {#prop-fingers}

The list of fingers that are currently in the area.

## Method Descriptions

### has_finger (finger: [Finger.Type](/reference/lib--utils--touch--finger.html#enum-Type)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#has-finger}

Checks if a specific finger is currently in the area.
