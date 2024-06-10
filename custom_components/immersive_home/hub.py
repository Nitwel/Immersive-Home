from __future__ import annotations

import asyncio

from homeassistant.core import HomeAssistant


class Hub:
    manufacturer = "Immersive Home"

    def __init__(self, hass: HomeAssistant) -> None:
        self._hass = hass
        self.devices = {}

    def add_device(self, device: Device) -> None:
        self.devices[device.id] = device

    def get_device(self, device_id: str) -> Device:
        return self.devices.get(device_id)


class Device:
    def __init__(self, device_id: str, name: str, version: str, platform: str) -> None:
        self.id = device_id
        self.name = name
        self.version = version
        self.platform = platform
        self.room = None

        self._callbacks = set()

    def set_room(self, room: str) -> None:
        self.room = room

        asyncio.create_task(self.publish_updates())

    def add_callback(self, callback: callable[[], None]) -> None:
        """Register callback, called when Roller changes state."""
        self._callbacks.add(callback)

    def remove_callback(self, callback: callable[[], None]) -> None:
        """Remove previously registered callback."""
        self._callbacks.discard(callback)

    async def publish_updates(self) -> None:
        """Schedule call all registered callbacks."""
        for callback in self._callbacks:
            callback()
