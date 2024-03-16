# Event System

While Godot ships with it's own event system, we have implemented our own event system to make it more similar to the event system in Browsers and to streamline event handling in the app.

Full reference can be found in the [Event System](/reference/lib--globals--event_system.html) documentation.

## Focus handling

By default, every Node that has the `ui_focus` group is able to receive focus. When a node receives focus, the **_on_focus_in(event: [EventFocus](/reference/EventFocus.html))** method is called. When a node loses focus, the **_on_focus_out(event: [EventFocus](/reference/EventFocus.html))** method is called.