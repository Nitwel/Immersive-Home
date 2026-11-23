# Building


1. Follow the following [guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html) to setup exporting for android.
2. Make sure to reuse any existing `debug.keystore` when updating an app
3. Don't forget to set the `JAVA_HOME` variable and restart Godot to take effect
4. Install the Android build template (**Project → Install Android Build Template**). The [Godot OpenXR Vendors](https://github.com/GodotVR/godot_openxr_vendors) plugin (v5.2.0) is already included in `app/addons/godotopenxrvendors`, so it doesn't need to be installed separately.

You now should be able to export the app to Android.

::: tip
```xml
<uses-feature android:name="com.oculus.feature.BOUNDARYLESS_APP" android:required="false" />
```
This can be added to the `AndroidManifest.xml` to disable the boundary system when the app is running.
:::
