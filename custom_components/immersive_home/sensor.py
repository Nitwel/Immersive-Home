"""Platform for sensor integration."""

from __future__ import annotations

from homeassistant.components.sensor import SensorEntity
from homeassistant.core import HomeAssistant
from homeassistant.helpers.entity_platform import AddEntitiesCallback
from homeassistant.helpers.typing import ConfigType, DiscoveryInfoType

from .const import DOMAIN
from .hub import Device, Hub

import logging

_LOGGER = logging.getLogger(__name__)


async def async_setup_entry(
    hass: HomeAssistant,
    config: ConfigType,
    async_add_entities: AddEntitiesCallback,
    discovery_info: DiscoveryInfoType | None = None,
) -> None:
    """Set up the sensor platform."""
    _LOGGER.info("Setting up sensor platform")

    hub: Hub = hass.data[DOMAIN]["hub"]

    for device in hub.devices.values():
        async_add_entities([RoomSensor(device)])


class RoomSensor(SensorEntity):
    """Representation of a Sensor."""

    def __init__(self, device: Device) -> None:
        """Initialize the sensor."""
        self._attr_name = f"{device.name} Room"
        self._attr_unique_id = f"{device.id}_room"
        self._device = device
        self._attr_should_poll = False

    @property
    def device_info(self):
        return {
            "identifiers": {(DOMAIN, self._device.id)},
        }

    @property
    def state(self):
        return self._device.room

    @property
    def available(self):
        return True

    async def async_added_to_hass(self):
        """Run when this Entity has been added to HA."""
        # Sensors should also register callbacks to HA when their state changes
        self._device.add_callback(self.async_write_ha_state)

    async def async_will_remove_from_hass(self):
        """Entity being removed from hass."""
        # The opposite of async_added_to_hass. Remove any registered call backs here.
        self._device.remove_callback(self.async_write_ha_state)
