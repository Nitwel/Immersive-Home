# Quick Start Guide

This guide will help you get started with installing and configuring the app.

## Prerequisites

The app requires that you have hosted [Home Assistant](https://www.home-assistant.io/) somewhere in your network or accessible from the internet. Without one, you can still try the app in [Demo Mode](/getting-started/demo-mode).

The app currently only supports the **Meta Quest 2, Pro, 3 and 3S**, other headsets like Pico 4 might work but are not officially supported yet.

## Download

You can download the app from the following sources:

- [Meta App Lab](https://www.oculus.com/experiences/quest/7533875049973382/) for $4.99 USD
- [Itch.io](https://nitwel.itch.io/immersive-home) for $4.99 USD
- [SideQuest](https://sidequestvr.com/app/26827/immersive-home) for free
- [GitHub](https://github.com/Nitwel/Immersive-Home/releases/latest/download/Android.zip) for free

::: info
The app is free to use, but if you want to support the project, you can buy it from the Meta App Lab or Itch.io. The benefit of buying it from the App Lab is that you will get automatic updates.
:::

## Installation to the Headset

If you bought the app from the Meta App Lab, you can skip this step.

In order to install the app on your headset, you will need to use [SideQuest](https://sidequestvr.com/setup-howto) to install APK files to the headset.

1. Download the APK from the source you chose.
2. Connect your headset to your computer.
3. Open the [SideQuest](https://sidequestvr.com/setup-howto) app.
4. Drag and drop the APK file into the SideQuest window.

## Creating a Token to access Home Assistant

In order to access your Home Assistant instance from the app, you will need to create a Long-Lived Access Token.

In the Home Assistant Dashboard, do the following:

1. Click on your user profile in the bottom left corner.
2. Scroll to the bottom and click on **create token** under "Long-Lived Access Tokens".

::: tip
You can use a pastebin like [immho.me](https://immho.me) to access your token from the headset. Simply paste the token and click **Save**. You can then access the token from the headset using the URL you got redirected to. E.g. `https://immho.me/upload/your-token`. `/upload/` can be replaced with `/u/`.
:::

![Home Assistant Dashboard](/img/setup-1.jpg)

3. Open the Menu in the app by either:
    - Pressing the **Menu** button on the left controller.
    - making the pinch gesture with the left hand while you palm points into your direction.

   Then open the settings panel with the gear button at the bottom of the menu's side bar.
4. Enter the URL of your Home Assistant instance and the token you just created. Make sure to change `http` -> `ws` or `https` -> `wss` in the URL.
    - The app searches your network for Home Assistant when the URL is empty. Press the search button next to the URL field to search again. If more than one install is found, press it again to go through them.

::: tip Scan the token as a QR code (Meta Quest)
Turn the token into a QR code, e.g. with a QR code generator on your computer, and show it on your screen. In the app, select the token field and press the QR code button on the keyboard, then look at the QR code. The app fills in the token and connects right away. If the URL is still empty, it searches your network for Home Assistant first.

The QR code can also hold the URL of your instance (e.g. `http://homeassistant.local:8123`), or both as `{"url": "http://homeassistant.local:8123", "token": "..."}`.

QR code scanning needs Horizon OS v83 or newer and asks for the spatial data permission the first time.
:::

::: tip
If you have used a pastebin to store your token, open the Browser on your headset and enter your pastebin URL. You can then copy the token from there.
:::

5. Finally, by clicking the **Connect** button, the app will try to connect to your Home Assistant instance. If everything is correct, you will see the text change to **Connected** below the button.

![Setting Panel in the app](/img/setup-2.jpg)

## What's next?

You successfully connected the app to Home Assistant. Next up you have to configure the rooms, read more about it in the [Room Setup](/getting-started/room-setup) section.

::: warning
Rooms have to be configured first, before you can add entities to them.
:::

Once your rooms are set up, you can [place devices](/getting-started/placing-devices) in them and get an overview of your whole home in the [Map View](/getting-started/map-view). Installing the [Home Assistant integration](/vendor-integration/home-assistant) also syncs your floor plan to Home Assistant and lets you show it on your dashboards.