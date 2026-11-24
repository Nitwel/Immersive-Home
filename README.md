![logo](app/assets/banner.png)

#  🏠 Introduction

Immersive Home is project to bring Smart Home and Mixed Reality technologies together for an intuitive and immersive experience.

<a href="https://immersive-home.org" target="_blank" style="text-decoration: none !important">
	<img height="32" src="app/assets/badges/website.png" alt="Badge linking to our website" />
</a>

<a href="https://discord.gg/DWWtDfVeus" target="_blank" style="text-decoration: none !important">
	<img height="32" src="app/assets/badges/discord.png" alt="Badge linking to our discord" />
</a>

<a href="https://www.oculus.com/experiences/quest/7533875049973382/" target="_blank" style="text-decoration: none !important">
	<img height="32" src="app/assets/badges/meta.png" alt="Badge linking to Meta App Lab" />
</a>

<a href="https://github.com/Nitwel/Immersive-Home/releases/latest/download/Android.zip" target="_blank" style="text-decoration: none !important">
	<img height="32" src="app/assets/badges/github.png" alt="Badge linking to GitHub" />
</a>

<a href="https://nitwel.itch.io/immersive-home" target="_blank" style="text-decoration: none !important">
	<img height="32" src="app/assets/badges/itch.png" alt="Badge linking to itch.io" />
</a>

<a href="https://sidequestvr.com/app/26827/immersive-home" target="_blank" style="text-decoration: none !important">
	<img height="32" src="app/assets/badges/sidequest.png" alt="Badge linking to sidequest" />
</a>

## Documentation

For users: [https://docs.immersive-home.org/](https://docs.immersive-home.org/)
For developers: [https://docs.immersive-home.org/development/](https://docs.immersive-home.org/development/)

## Home Assistant Integration

The Immersive Home app works with Home Assistant on its own. The optional integration adds a room sensor for every headset, syncs the floor plan you set up in the headset to Home Assistant, and ships two floor plan dashboard cards. It needs Home Assistant 2024.7 or newer.

### Installation

1. Open HACS in Home Assistant, search for **Immersive Home** and download it.
   Or download [Integration.zip](https://github.com/Nitwel/Immersive-Home/releases/latest/download/Integration.zip) and extract it into `custom_components/immersive_home`.
2. Restart Home Assistant.
3. Go to **Settings → Devices & services**, click **Add integration**, search for **Immersive Home** and confirm. This only has to be done once.

### Usage

- **Headsets:** start the app and connect it to Home Assistant. Each headset adds itself as its own device under **Settings → Devices & services → Immersive Home**, you don't add headsets by hand.
- **Room sensor:** every headset gets a **Room** sensor with the name of the room it is in, for automations based on where you are in your home.
- **Floor plan cards:** when you save rooms, doors or placed devices in the app, the floor plan is sent to Home Assistant. Two cards show it with the live state of your devices, a 2D floor plan (`custom:immersive-home-floor-plan-card`) and a 3D dollhouse (`custom:immersive-home-floor-plan-3d-card`). They load automatically, add them from the card picker in the dashboard editor. Both have a visual editor.

All options and details: [docs.immersive-home.org/vendor-integration/home-assistant](https://docs.immersive-home.org/vendor-integration/home-assistant)


## Features

- **Fast and Intuitive control over IoT devices**
- **Live overview over your smart home**
- **Build in Voice Assistant for more control**
- **Map View with a live dollhouse of your house and everyone's positions**
- **Support for 40 Home Assistant entity domains**
- **Floor plan sync with 2D and 3D floor plan cards for Home Assistant**
- **Natural interactions with hands**
- **Advanced automations based on position in room**

## Support the Project

💕 If you like to see the project grow to support more devices and interaction methods, consider supporting the project using these methods:

- Donate using [PayPal]( https://paypal.me/nitwel) or [GitHub Sponsors](https://github.com/sponsors/Nitwel)
- Buying the app on [Meta App Lab](https://www.oculus.com/experiences/quest/7533875049973382/) or [itch.io](https://nitwel.itch.io/immersive-home)
- Contributing to the project by creating issues or pull requests

## Supported Devices

**Smart Home Platforms**
- [Home Assistant](https://www.home-assistant.io/)

**Mixed Reality Headsets**
- Meta Quest 2 / Pro / 3 / 3S