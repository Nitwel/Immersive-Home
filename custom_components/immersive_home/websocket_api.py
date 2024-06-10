"""Home Assistant websocket API."""

from __future__ import annotations

from typing import Any

import voluptuous as vol

from homeassistant.components import websocket_api
from homeassistant.core import HomeAssistant, callback

from .const import DOMAIN
from .hub import Device, Hub


@callback
def async_setup_commands(hass):
    """Set up the mobile app websocket API."""
    websocket_api.async_register_command(hass, handle_register)
    websocket_api.async_register_command(hass, handle_update)


@callback
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
    """Set up a new Immersive Home Device."""

    hub: Hub = hass.data[DOMAIN]["hub"]

    hub.add_device(
        Device(
            msg["device_id"],
            msg["name"],
            msg["version"],
            msg["platform"],
        )
    )

    await hass.async_create_task(
        hass.config_entries.flow.async_init(
            DOMAIN, data=msg, context={"source": "registration"}
        )
    )

    connection.send_result(msg["id"], {"result": "success"})


@callback
@websocket_api.websocket_command(
    {
        vol.Required("type"): "immersive_home/update",
        vol.Required("device_id"): str,
        vol.Optional("room"): str,
    }
)
def handle_update(
    hass: HomeAssistant,
    connection: websocket_api.ActiveConnection,
    msg: dict[str, Any],
) -> None:
    """Update data of a Immersive Home Device."""

    hub: Hub = hass.data[DOMAIN]["hub"]
    device = hub.get_device(msg["device_id"])

    if device is None:
        connection.send_error(msg["id"], "device_not_found", "Device not found")
        return

    if "room" in msg:
        device.set_room(msg["room"])

    connection.send_result(msg["id"], {"result": "success"})
