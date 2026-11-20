"""Home Assistant websocket API."""

from __future__ import annotations

from typing import Any

import voluptuous as vol

from homeassistant.components import websocket_api
from homeassistant.core import HomeAssistant, callback

from .const import DOMAIN
from .hub import REGISTRATION_FIELDS, Hub


@callback
def async_setup_commands(hass: HomeAssistant) -> None:
    """Set up the Immersive Home websocket API."""
    websocket_api.async_register_command(hass, handle_register)
    websocket_api.async_register_command(hass, handle_update)


@websocket_api.websocket_command(
    {
        vol.Required("type"): "immersive_home/register",
        vol.Required("device_id"): str,
        vol.Required("name"): str,
        vol.Required("version"): str,
        vol.Required("platform"): str,
    }
)
@websocket_api.async_response
async def handle_register(
    hass: HomeAssistant,
    connection: websocket_api.ActiveConnection,
    msg: dict[str, Any],
) -> None:
    """Register a headset, creating its config entry on the first connect."""

    hub: Hub = hass.data[DOMAIN]["hub"]
    registration = {key: msg[key] for key in REGISTRATION_FIELDS}

    hub.get_or_create_device(registration)

    await hass.config_entries.flow.async_init(
        DOMAIN, data=registration, context={"source": "registration"}
    )

    connection.send_result(msg["id"], {"result": "success"})


@websocket_api.websocket_command(
    {
        vol.Required("type"): "immersive_home/update",
        vol.Required("device_id"): str,
        vol.Optional("room"): str,
    }
)
@callback
def handle_update(
    hass: HomeAssistant,
    connection: websocket_api.ActiveConnection,
    msg: dict[str, Any],
) -> None:
    """Update the data of a headset."""

    hub: Hub = hass.data[DOMAIN]["hub"]
    device = hub.get_device(msg["device_id"])

    if device is None:
        connection.send_error(msg["id"], "device_not_found", "Device not found")
        return

    if "room" in msg:
        device.set_room(msg["room"])

    connection.send_result(msg["id"], {"result": "success"})
