# EventPointer
**Inherits:** [EventBubble](/reference/EventBubble.html)
    
## Description

Triggered when the raycast of the controller or hand hits or clicks on an object.

## Properties

| Name                         | Type                                                                          | Default |
| ---------------------------- | ----------------------------------------------------------------------------- | ------- |
| [initiator](#prop-initiator) | [Initiator](/reference/lib--utils--pointer--initiator.html)                   |         |
| [ray](#prop-ray)             | [RayCast3D](https://docs.godotengine.org/de/4.x/classes/class_raycast3d.html) |         |







## Constants

### Initiator = `<Object>` {#const-Initiator}

No description provided yet.

## Property Descriptions

### initiator: [Initiator](/reference/lib--utils--pointer--initiator.html) {#prop-initiator}

Either the controller or the hand that triggered the event.

### ray: [RayCast3D](https://docs.godotengine.org/de/4.x/classes/class_raycast3d.html) {#prop-ray}

The raycast that collided with the target.
