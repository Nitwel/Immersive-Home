# EventTouch
**Inherits:** [EventBubble](/reference/EventBubble.html)
    
## Description

Emitted when a finger enters or leaves a FingerArea.

## Properties

| Name                     | Type                                                  | Default |
| ------------------------ | ----------------------------------------------------- | ------- |
| [fingers](#prop-fingers) | [Finger](/reference/lib--utils--touch--finger.html)[] |         |

## Methods

| Returns                                                                   | Name                                                                                                    |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) | [has_finger](#has-finger) ( finger: [int](https://docs.godotengine.org/de/4.x/classes/class_int.html) ) |





## Constants

### Finger = `<Object>` {#const-Finger}

No description provided yet.

## Property Descriptions

### fingers: [Finger](/reference/lib--utils--touch--finger.html)[] {#prop-fingers}

The list of fingers that are currently in the area.

## Method Descriptions

###  has_finger (finger: [int](https://docs.godotengine.org/de/4.x/classes/class_int.html)  ) -> [Variant](https://docs.godotengine.org/de/4.x/classes/class_variant.html) {#has-finger}

Checks if a specific finger is currently in the area.
