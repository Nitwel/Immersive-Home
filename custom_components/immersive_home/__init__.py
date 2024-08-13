"""The Immersive Home integration."""

from __future__ import annotations

from homeassistant.config_entries import ConfigEntry
from homeassistant.const import Platform
from homeassistant.core import HomeAssistant
from homeassistant.helpers import device_registry as dr
from homeassistant.helpers.typing import ConfigType

from . import hub, websocket_api
from .const import DOMAIN

import logging

_LOGGER = logging.getLogger(__name__)

PLATFORMS: list[Platform] = [Platform.SENSOR, Platform.BINARY_SENSOR]


async def async_setup(hass: HomeAssistant, config: ConfigType) -> bool:
    """Set up the ImmersiveHome component."""

    hass.data[DOMAIN] = {
        "hub": hub.Hub(hass),
    }

    websocket_api.async_setup_commands(hass)
    return True


async def async_setup_entry(hass: HomeAssistant, entry: ConfigEntry) -> bool:
    """Set up ImmersiveHome from a config entry."""
    _LOGGER.info("Setting up entry %s", entry.entry_id)
    registration = entry.data

    hass.data.setdefault(DOMAIN, {})

    device_registry = dr.async_get(hass)

    device_registry.async_get_or_create(
        config_entry_id=entry.entry_id,
        identifiers={(DOMAIN, registration["device_id"])},
        manufacturer="Someone",
        model=registration["platform"],
        name=registration["name"],
        sw_version=registration["version"],
    )

    await hass.config_entries.async_forward_entry_setups(entry, PLATFORMS)

    return True


async def async_unload_entry(hass: HomeAssistant, entry: ConfigEntry) -> bool:
    """Unload a config entry."""
    unload_ok = await hass.config_entries.async_unload_platforms(entry, PLATFORMS)

    return unload_ok
