# Testing

## Without a VR Headset

In order to test without a headset, press the run project (F5) button in Godot and ignore the prompt that OpenXR failed to start. To simulate the headset and controller movement, we're using the [XR Input Simulator](https://godotengine.org/asset-library/asset/1775) addon. Click at the link to get a list of the supported controls.

## With a VR Headset

To test the app with a VR headset, make sure you are able to export the project to Android. Follow the [Building](development/building.md) guide to setup the project for Android.

When everything is setup correctly, you can connect your Headset to your computer and press the `Export with Remote Debug` button in Godot. This will start the app on your headset and connect the Godot Editor to the app. You can now see the logs and errors in the Godot Editor while the app is running on the headset.