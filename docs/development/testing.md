# Testing

## Without a VR Headset

In order to test without a headset, press the run project (F5) button in Godot and ignore the prompt that OpenXR failed to start. To simulate the headset and controller movement, we're using the [XR Input Simulator](https://godotengine.org/asset-library/asset/1775) addon. Click at the link to get a list of the supported controls.

## Desktop Galleries

Two gallery scenes let you work on the UI and the entity widgets on desktop, without a headset or a Home Assistant server. Run them with **Run Current Scene** (F6) in Godot. The mouse drives the same pointer pipeline as a controller ray.

- `app/test/ui/ui_gallery.tscn` shows every UI component (buttons, inputs, sliders, selects, the keyboard, panels in different shapes, …).
- `app/test/content/entities/entity_gallery.tscn` shows every entity widget in its main states. A mock Home Assistant simulates the services, so clicking a widget changes its state. The last cell lists Home Assistant domains that don't have a widget yet.

**Controls:** left mouse is the trigger, right mouse the grip, middle drag orbits, Shift + middle drag pans and the mouse wheel zooms. Press `1`–`9` to focus a cell, `0` or `F` to show everything, `F1` to type with your PC keyboard into a focused input and `P` to save a screenshot to `user://ui_gallery/`. In the entity gallery, `U` sends random state updates to every entity.

**Command line:** both galleries accept flags after `--` to take screenshots and script input, for example:

```bash
godot --path app res://test/ui/ui_gallery.tscn -- --focus=slider --screenshot=slider.png
```

Useful flags are `--screenshot=<path.png>`, `--focus=<cell>`, `--size=<w>x<h>`, `--click=<x>,<y>`, `--type=<text>`, `--grab`, `--drag` and `--pinch` for scripted grabs, drags and two-hand pinches, and `--edge-cases` (entity gallery) for minimal states that used to crash. The full list is at the top of `ui_gallery.gd` and `entity_gallery.gd`.

## Demo Mode

The [demo mode](/getting-started/demo-mode) runs the whole app against made-up devices, which is handy for testing without Home Assistant. Its adapter lives in `app/lib/home_apis/demo/`: `simulated_api.gd` simulates Home Assistant's services (the entity gallery uses it too), `demo.gd` adds the demo home's devices, drifting sensors and people, and `demo_house.gd` holds the apartment.

`app/test/lib/home_apis/demo/demo_check.tscn` checks that the apartment, the devices and the simulation fit together and that every placed widget can be created:

```bash
godot --headless --path app res://test/lib/home_apis/demo/demo_check.tscn
```

It prints `demo_check: PASS` or the failures. Run it without `--headless` and add `-- --screenshot=<path.png>` to also render the apartment as a dollhouse.

## With a VR Headset

To test the app with a VR headset, make sure you are able to export the project to Android. Follow the [Building](/development/building) guide to setup the project for Android.

When everything is setup correctly, you can connect your Headset to your computer and press the `Export with Remote Debug` button in Godot. This will start the app on your headset and connect the Godot Editor to the app. You can now see the logs and errors in the Godot Editor while the app is running on the headset.