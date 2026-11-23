# Room Setup

## Video Tutorial

<iframe src="https://www.youtube-nocookie.com/embed/8t66SH6ZbEE?si=-yEmwCJpE2mvjg6Z" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

::: info
The video was recorded with an older version of the app. The steps are the same, but the Room Setup panel looks different since v0.7.0.
:::

## Introduction

In order to be able to add entities into your virtual home, you have to configure the rooms first. Otherwise you will get the message "Entities can only be placed inside a room".

The Room Setup panel is the second button in the menu's side bar (the cube icon), right below **Widgets**. It has three tabs:

- **Overview**: a floor plan of your home with the number of rooms and doors, and the [reference](#reference-point) that keeps your rooms lined up with your real home.
- **Rooms**: add, edit, rename and delete rooms.
- **Doors**: add doors between rooms.

Each tab shows the floor plan on the left, in the same colours the rooms have in the [Map View](/getting-started/map-view). The actions for the selected room or door are on the right.

![The Overview tab of the Room Setup panel: the floor plan, the number of rooms and doors, and the reference buttons](/img/room-setup-overview.webp)

## Adding a Room

1. Open the Menu and open the Room Setup panel.
2. Open the **Rooms** tab.
3. Enter the name of the room in the name field. A free name like "Room 1" is filled in for you.
4. Click on **Add room**.
5. Click in a corner on the floor to add the initial corner.

![Corner of Room](/img/room-setup-3.png)

6. Adjust the height of the room by moving the upper circle until it matches the height of the room.
7. Click on another corner on the ceiling to add the second corner.
8. Continue adding corners to the ceiling until the room is fully enclosed.
9. Click on **Save** to save the room.

![Room fully configured](/img/room-setup-4.png)

::: tip Use the room you scanned on your Quest
While a room is being edited, the **Sync from Quest** button takes the walls and the height from the room your Quest has scanned (its space setup), so you don't have to click every corner by hand.
:::

A room needs at least 3 corners. Rooms with fewer corners are removed when you save them.

## Editing a Room

Tap a room on the floor plan to select it. The selected room gets an outline in its colour and the other rooms are dimmed.

- **Edit** lets you move its corners and rename it. Press **Save** when you are done.
- **Delete** removes the room.

![The Rooms tab with the Living Room selected on the floor plan, its name, and the Edit and Delete buttons](/img/room-setup-rooms.webp)

## Adding Doors

Doors are shown as openings in the walls in the [Map View](/getting-started/map-view) and on the [floor plan cards](/vendor-integration/home-assistant#floor-plan-cards) in Home Assistant.

1. Open the **Doors** tab.
2. Click on **Add door**.
3. Move the door's corners to where the door is in your room, between two rooms.
4. Press **Save**.

Tap a door on the floor plan to select, edit or delete it.

![The Doors tab with the door between the living room and the bedroom selected](/img/room-setup-doors.webp)

## Reference Point

After a headset restart or after you redo your boundary, the headset can move its tracking space, which would put your rooms and devices in the wrong place. The reference keeps them lined up with your real home.

### Automatic alignment (Meta Quest)

When you save the reference or your rooms, the app places a spatial anchor at the first corner of the reference. On every start it checks where the anchor is now and moves the whole house back into place: rooms, devices and doors. You don't need to do anything for this.

Small differences (under 1 cm or 0.5°) are ignored, and nothing is moved while you are editing a room, a door or the reference.

### Setting the reference

1. Go to the **Overview** tab of the Room Setup panel.
2. Click on **Edit** (pen icon).
3. Move the reference point to a fixed spot, for example an image hanging on the wall or a window.
4. Press **Save**.

The result should look something like this:

![Reference Point next to Image](/img/reference-point.png)

### Fixing the alignment by hand

If your rooms are still out of place:

1. Go to the **Overview** tab of the Room Setup panel.
2. Click on **Fix** (band aid icon).
3. Move the reference point back to its original position.
4. Press **Save**.

### Aligning with a QR code

You can also use a printed QR code as the reference. This works on headsets that support marker tracking (Meta Quest with Horizon OS v83 or newer).

1. Put a QR code somewhere it won't move, for example on a wall.
2. While your rooms are lined up correctly, press **Link** in the **Overview** tab and look at the QR code. The app remembers where it is.
3. Whenever the rooms are out of place, press **Scan** and look at the same QR code. The house is moved back into place.

Only the linked QR code is accepted, and each scan averages several detections for a stable result. Fixing the alignment by hand also updates the linked QR code, so you don't have to link it again.
