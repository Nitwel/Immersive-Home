# Event System

While Godot ships with it's own event system, we have implemented our own event system to make it more similar to the event system in Browsers and to streamline event handling in the app.

There are two types of base events, [Events](/reference/Event.html) which get directly emitted by the [EventSystem](/reference/lib--globals--event_system.html) and [BubbleEvents](/reference/EventBubble.html) which first walk through the scene tree starting at the [target](/reference/EventBubble.html#prop-target) node until the root node is reached and then get emitted by the [EventSystem](/reference/lib--globals--event_system.html). This can be seen in the diagram below.

![Event System](/img/event-walking.svg)

Full reference can be found in the [Event System](/reference/lib--globals--event_system.html) documentation.

## Focus handling

By default, every Node that has the `ui_focus` group is able to receive focus. When a node receives focus, the **_on_focus_in(event: [EventFocus](/reference/EventFocus.html))** method is called. When a node loses focus, the **_on_focus_out(event: [EventFocus](/reference/EventFocus.html))** method is called.

The `ui_focus_skip` group can be added to a node to skip focus when clicking on it.
The `ui_focus_stop` group prevents focus entirely on itself and its children. Useful for the Virtual Keyboard.