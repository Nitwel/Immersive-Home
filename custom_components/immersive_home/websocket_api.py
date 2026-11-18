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
    websocket_api.async_register_command(hass, handle_add_area)
    websocket_api.async_register_command(hass, handle_update_area)
    websocket_api.async_register_command(hass, handle_remove_area)


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

    if hub.get_device(msg["device_id"]) is not None:
        connection.send_result(msg["id"], {"result": "success"})
        return

    hub.add_device(msg["device_id"], msg["name"], msg["version"], msg["platform"])

    await hass.async_create_task(
        hass.config_entries.flow.async_init(
            DOMAIN, data=msg, context={"source": "registration"}
        )
    )

    connection.send_result(msg["id"], {"result": "success"})


@callback
@websocket_api.websocket_command(
    {
        vol.Required("type"): "immersive_home/add_area",
        vol.Required("device_id"): str,
        vol.Required("area_id"): int,
        vol.Required("name"): str,
    }
)
def handle_add_area(
    hass: HomeAssistant,
    connection: websocket_api.ActiveConnection,
    msg: dict[str, Any],
) -> None:
    """Add a new area to a Immersive Home Device."""

    hub: Hub = hass.data[DOMAIN]["hub"]
    device = hub.get_device(msg["device_id"])

    if device is None:
        connection.send_error(msg["id"], "device_not_found", "Device not found")
        return

    device.add_area(msg["area_id"], msg["name"])

    connection.send_result(msg["id"], {"result": "success"})


@callback
@websocket_api.websocket_command(
    {
        vol.Required("type"): "immersive_home/update_area",
        vol.Required("device_id"): str,
        vol.Required("area_id"): int,
        vol.Required("active"): bool,
    }
)
def handle_update_area(
    hass: HomeAssistant,
    connection: websocket_api.ActiveConnection,
    msg: dict[str, Any],
) -> None:
    """Add a new area to a Immersive Home Device."""

    hub: Hub = hass.data[DOMAIN]["hub"]
    device = hub.get_device(msg["device_id"])

    if device is None:
        connection.send_error(msg["id"], "device_not_found", "Device not found")
        return

    device.set_area(msg["area_id"], msg["active"])

    connection.send_result(msg["id"], {"result": "success"})


@callback
@websocket_api.websocket_command(
    {
        vol.Required("type"): "immersive_home/remove_area",
        vol.Required("device_id"): str,
        vol.Required("area_id"): int,
    }
)
def handle_remove_area(
    hass: HomeAssistant,
    connection: websocket_api.ActiveConnection,
    msg: dict[str, Any],
) -> None:
    """Add a new area to a Immersive Home Device."""

    hub: Hub = hass.data[DOMAIN]["hub"]
    device = hub.get_device(msg["device_id"])

    if device is None:
        connection.send_error(msg["id"], "device_not_found", "Device not found")
        return

    device.remove_area(msg["name"])

    connection.send_result(msg["id"], {"result": "success"})


@callback
@websocket_api.websocket_command(
    {
        vol.Required("type"): "immersive_home/update_room",
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
