"""Platform for sensor integration."""

from __future__ import annotations

from homeassistant.components.sensor import RestoreSensor
from homeassistant.config_entries import ConfigEntry
from homeassistant.core import HomeAssistant
from homeassistant.helpers.device_registry import DeviceInfo
from homeassistant.helpers.entity_platform import AddEntitiesCallback

from .const import DOMAIN
from .hub import Device


async def async_setup_entry(
    hass: HomeAssistant,
    entry: ConfigEntry[Device],
    async_add_entities: AddEntitiesCallback,
) -> None:
    """Set up the room sensor of the entry's headset."""
    async_add_entities([RoomSensor(entry.runtime_data)])


class RoomSensor(RestoreSensor):
    """The room the headset is currently in."""

    _attr_has_entity_name = True
    _attr_name = "Room"
    _attr_icon = "mdi:floor-plan"
    _attr_should_poll = False

    def __init__(self, device: Device) -> None:
        """Initialize the sensor."""
        self._device = device
        self._attr_unique_id = f"{device.id}_room"
        self._attr_device_info = DeviceInfo(identifiers={(DOMAIN, device.id)})

    @property
    def native_value(self) -> str | None:
        return self._device.room

    async def async_added_to_hass(self) -> None:
        """Restore the last room and listen for updates of the device."""
        await super().async_added_to_hass()

        if self._device.room is None:
            last_data = await self.async_get_last_sensor_data()
            if last_data is not None and last_data.native_value is not None:
                self._device.room = str(last_data.native_value)

        self.async_on_remove(self._device.add_callback(self.async_write_ha_state))
