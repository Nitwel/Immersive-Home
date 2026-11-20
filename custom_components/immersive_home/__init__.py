"""The Immersive Home integration."""

from __future__ import annotations

from homeassistant.config_entries import ConfigEntry
from homeassistant.const import Platform
from homeassistant.core import HomeAssistant
from homeassistant.helpers import config_validation as cv
from homeassistant.helpers import device_registry as dr
from homeassistant.helpers.typing import ConfigType

from . import websocket_api
from .const import DOMAIN, MANUFACTURER
from .hub import Device, Hub

PLATFORMS: list[Platform] = [Platform.SENSOR]

CONFIG_SCHEMA = cv.config_entry_only_config_schema(DOMAIN)

ImmersiveHomeConfigEntry = ConfigEntry[Device]


async def async_setup(hass: HomeAssistant, config: ConfigType) -> bool:
    """Set up the Immersive Home component."""

    hass.data[DOMAIN] = {
        "hub": Hub(hass),
    }

    websocket_api.async_setup_commands(hass)
    return True


async def async_setup_entry(hass: HomeAssistant, entry: ImmersiveHomeConfigEntry) -> bool:
    """Set up a headset from its config entry.

    The device is rebuilt from the stored registration, so it is available again
    after a restart, before the headset reconnects.
    """
    hub: Hub = hass.data[DOMAIN]["hub"]
    registration = entry.data

    device = hub.get_or_create_device(registration)
    entry.runtime_data = device

    device_registry = dr.async_get(hass)
    device_registry.async_get_or_create(
        config_entry_id=entry.entry_id,
        identifiers={(DOMAIN, device.id)},
        manufacturer=MANUFACTURER,
        model=device.platform,
        name=device.name,
        sw_version=device.version,
    )

    await hass.config_entries.async_forward_entry_setups(entry, PLATFORMS)

    return True


async def async_unload_entry(hass: HomeAssistant, entry: ImmersiveHomeConfigEntry) -> bool:
    """Unload a config entry."""
    return await hass.config_entries.async_unload_platforms(entry, PLATFORMS)


async def async_remove_entry(hass: HomeAssistant, entry: ImmersiveHomeConfigEntry) -> None:
    """Forget the headset when its config entry is deleted."""
    hub: Hub = hass.data[DOMAIN]["hub"]
    hub.remove_device(entry.data["device_id"])
