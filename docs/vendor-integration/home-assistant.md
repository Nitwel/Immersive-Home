# Integration with Home Assistant

This guide will help you install the Immersive Home integration into Home Assistant. The app will automatically detect the presence of the integration and will sync the room your headset is in with Home Assistant.

![Integration inside Home Assistant](/img/ha-integration.png)

## Installation

1. Download the latest release from [GitHub](https://github.com/Nitwel/Immersive-Home/releases/latest/download/Integration.zip)
2. Extract the zip file
3. Copy the `immersive_home` folder into the `custom_components` folder of your Home Assistant instance
4. Add the following line to your `configuration.yaml` file:

```yaml
immersive_home:

```

5. Restart Home Assistant

If everything was done correctly, you should see the integration in the integrations panel of Home Assistant.