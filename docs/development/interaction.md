# Interaction System

The app currently supports 3 different types of interaction techniques:

- **Using controllers with raycast**
- **Using hands with raycast**
- **Using hands with direct touch**

The interaction system, like the [Event System](/development/event-system.html), is heavily inspired by the interaction system in browsers. Interaction Events can be broken down into 2 categories, [Pointer Events](/reference/EventPointer.html) initiated by a raycast and [Touch Events](/reference/TouchEvent.html) initiated by a collision shape in the tip of the fingers. Pointer Events](/reference/EventPointer.html)

## Pointer Events

When pressing the trigger button on the back of a controller or doing a pinch gesture with thumb and index finer an `on_press_down` event is triggered containing a [EventPointer](/reference/EventPointer.html) which holds information about the ray and initiator of the event. If the trigger button or pinch gesture is released before 400ms pass, an `on_press_up` and `on_click` event is triggered. If the trigger button or pinch gesture is held for more than 400ms, an `on_press_move` event is triggered each physics process and when releasing, only the `on_press_up` event is triggered.

![Event Order](/img/event-order.svg)

The same logic can be applied to **grab** (`on_grab_down`, `on_grab_move` and `on_grab_up`) events, here the event family is triggered by the grip button on the controller or by doing a pinch gesture with thumb and middle finger.

### Pinch Gesture

The pinch gesture is implemented by checking the distance between the thumb and each finger and if the distance is smaller than 3cm, the pinch gesture is detected.

## Touch Events

Touch events are triggered when the collision shape present in the tip of the fingers enters another collision area. The `on_touch_enter` event is triggered when the collision shape enters the area, the `on_touch_move` event is triggered each physics process while the collision shape is inside the area and the `on_touch_leave` event is triggered when the collision shape leaves the area.

![Touch Event Order](/img/touch-event.svg)

## Hover (ray) Events

Each frame the ray is casted from the controller or hand and in case that the ray collides with a collision node, the `on_ray_enter` event is triggered. If the ray was already colliding with another object the previous frame, the `on_ray_leave` event is triggered on the old node.