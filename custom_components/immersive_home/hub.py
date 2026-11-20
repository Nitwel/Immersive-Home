"""In-memory state of the connected Immersive Home headsets."""

from __future__ import annotations

from collections.abc import Callable
from typing import Any

from homeassistant.core import HomeAssistant, callback

# Fields of a registration that are stored in the config entry.
REGISTRATION_FIELDS = ("device_id", "name", "version", "platform")


class Hub:
    """Keeps track of the known devices, keyed by device id."""

    def __init__(self, hass: HomeAssistant) -> None:
        self._hass = hass
        self.devices: dict[str, Device] = {}

    def get_device(self, device_id: str) -> Device | None:
        return self.devices.get(device_id)

    def get_or_create_device(self, registration: dict[str, Any]) -> Device:
        """Return the device of a registration, creating or updating it.

        The existing Device object is kept, so entities listening to it stay attached.
        """
        device = self.devices.get(registration["device_id"])

        if device is None:
            device = Device(
                registration["device_id"],
                registration["name"],
                registration["version"],
                registration["platform"],
            )
            self.devices[device.id] = device
        else:
            device.name = registration["name"]
            device.version = registration["version"]
            device.platform = registration["platform"]

        return device

    def remove_device(self, device_id: str) -> None:
        self.devices.pop(device_id, None)


class Device:
    """A headset running Immersive Home."""

    def __init__(self, device_id: str, name: str, version: str, platform: str) -> None:
        self.id = device_id
        self.name = name
        self.version = version
        self.platform = platform
        self.room: str | None = None

        self._callbacks: set[Callable[[], None]] = set()

    @callback
    def set_room(self, room: str) -> None:
        self.room = room
        self.publish_updates()

    @callback
    def add_callback(self, update_callback: Callable[[], None]) -> Callable[[], None]:
        """Register a callback that is called when the device changes.

        Returns a function that removes the callback again.
        """
        self._callbacks.add(update_callback)
        return lambda: self._callbacks.discard(update_callback)

    @callback
    def publish_updates(self) -> None:
        for update_callback in list(self._callbacks):
            update_callback()
