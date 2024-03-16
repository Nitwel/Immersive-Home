# Quick Start Guide

This guide will help you get started with installing and configuring the app.

## Prerequisites

The app requires that you have hosted [Home Assistant](https://www.home-assistant.io/) somewhere in your network or accessible from the internet.

The app currently only supports the **Meta Quest 2, Pro and 3**, other headsets like Pico 4 might work but are not officially supported yet.

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

![Home Assistant Dashboard](/img/setup-1.jpg)

3. Open the Menu in the app and open the settings panel by either:
    - Pressing the **Menu** button on the left controller.
    - making the pinch gesture with the left hand while you palm points into your direction.
4. Enter the URL of your Home Assistant instance and the token you just created. Make sure to change `http` -> `ws` or `https` -> `wss` in the URL.

::: tip
The fastest way to enter the token and URL is to send a message to your headset with the token and URL and then copy each part inside the headset.
The bottom right button on the keyboard will paste the copied text into the input field.
:::

5. Finally, by clicking the **Connect** button, the app will try to connect to your Home Assistant instance. If everything is correct, you will see the text change to **Connected** below the button.

![Setting Panel in the app](/img/setup-2.jpg)

## What's next?

You successfully connected the app to Home Assistant. Next up you have to configure the rooms, read more about it in the [Room Setup](/getting-started/room-setup) section.

::: warning
Rooms have to be configured first, before you can add entities to them.
:::