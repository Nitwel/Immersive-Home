"""The Immersive Home integration."""

from __future__ import annotations

from pathlib import Path

import voluptuous as vol

from homeassistant.components.frontend import add_extra_js_url
from homeassistant.components.http import StaticPathConfig
from homeassistant.config_entries import SOURCE_IMPORT, ConfigEntry
from homeassistant.const import Platform
from homeassistant.core import HomeAssistant
from homeassistant.helpers import device_registry as dr
from homeassistant.helpers import issue_registry as ir
from homeassistant.helpers.typing import ConfigType

from . import websocket_api
from .const import DOMAIN, FLOOR_PLAN_CARD, FRONTEND_URL, HUB_UNIQUE_ID, MANUFACTURER
from .floor_plan import FloorPlan
from .hub import Device, Hub

PLATFORMS: list[Platform] = [Platform.SENSOR]

# The integration is set up from the UI. Older versions needed an empty
# `immersive_home:` line in configuration.yaml, which is still accepted and
# imported into a config entry, so existing installs keep working.
CONFIG_SCHEMA = vol.Schema(
    {vol.Optional(DOMAIN): vol.Any(None, {})},
    extra=vol.ALLOW_EXTRA,
)

ImmersiveHomeConfigEntry = ConfigEntry[Device | None]


def is_hub_entry(entry: ConfigEntry) -> bool:
    """Whether the entry is the integration's own entry rather than a headset."""
    return entry.unique_id == HUB_UNIQUE_ID


async def async_setup(hass: HomeAssistant, config: ConfigType) -> bool:
    """Set up the Immersive Home component.

    Runs when the integration has a config entry (or the old YAML line), before
    the entries are set up. Registers the websocket commands headsets use to add
    themselves, and the floor plan cards.
    """

    floor_plan = FloorPlan(hass)
    await floor_plan.async_load()

    hass.data[DOMAIN] = {
        "hub": Hub(hass),
        "floor_plan": floor_plan,
    }

    websocket_api.async_setup_commands(hass)
    await _async_register_frontend(hass)

    if DOMAIN in config:
        hass.async_create_task(
            hass.config_entries.flow.async_init(
                DOMAIN, context={"source": SOURCE_IMPORT}, data={}
            )
        )
        ir.async_create_issue(
            hass,
            DOMAIN,
            "yaml_not_needed",
            is_fixable=False,
            severity=ir.IssueSeverity.WARNING,
            translation_key="yaml_not_needed",
        )
    else:
        ir.async_delete_issue(hass, DOMAIN, "yaml_not_needed")

    return True


async def _async_register_frontend(hass: HomeAssistant) -> None:
    """Serve the Lovelace cards and load them in the frontend, no resource needs adding."""
    frontend_dir = Path(__file__).parent / "frontend"

    await hass.http.async_register_static_paths(
        [StaticPathConfig(FRONTEND_URL, str(frontend_dir), True)]
    )

    # Browsers cache the card, the modification time makes them load a changed one.
    modified = await hass.async_add_executor_job(
        lambda: int((frontend_dir / FLOOR_PLAN_CARD).stat().st_mtime)
    )
    add_extra_js_url(hass, f"{FRONTEND_URL}/{FLOOR_PLAN_CARD}?v={modified}")


async def async_setup_entry(hass: HomeAssistant, entry: ImmersiveHomeConfigEntry) -> bool:
    """Set up a headset from its config entry.

    The device is rebuilt from the stored registration, so it is available again
    after a restart, before the headset reconnects. The hub entry has nothing to
    set up, async_setup already did its work.
    """
    if is_hub_entry(entry):
        entry.runtime_data = None
        return True

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
    if is_hub_entry(entry):
        return True

    return await hass.config_entries.async_unload_platforms(entry, PLATFORMS)


async def async_remove_entry(hass: HomeAssistant, entry: ImmersiveHomeConfigEntry) -> None:
    """Forget the headset when its config entry is deleted."""
    if is_hub_entry(entry):
        return

    hub: Hub = hass.data[DOMAIN]["hub"]
    hub.remove_device(entry.data["device_id"])
