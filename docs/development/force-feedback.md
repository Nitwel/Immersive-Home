# Force Feedback

In order to make interactions with hands feel more natural and immersive, multiple techniques can be applied to provide a sensor of haptic feedback while not directly simulating physical touch. 

The first technique is to overlay a virtual copy of the physical hand as hand tracking still has a bit of latency and jitter. The virtual hand reduces confusion when interacting with objects as the user can reference the virtual hand to compensate for these issues.

The second technique is to allow the virtual hand to collide with virtual objects in the scene. This is done to trick the brain into thinking that the hand is touching something. The brain perceives the virtual hand as its own hand and thus the collision with virtual objects feels like touching a real object.

## Implementation

There are several techniques for making the virtual hand collide with virtual objects. The one we chose to implement is to use a free floating spherical collision shape. Each physics frame a strong force is applied to the collision shape into the direction of the tip of the finger. 

![Force Feedback](/img/force-feedback.svg)

The virtual hand is moved so that the tip of the finger is at the position of the collision shape.

In case that the distance between the collision shape and the physical hand becomes too large, the collision shape is teleported back to the tip of the finger. That way we make sure that your virtual hand never gets stuck in the scene.
