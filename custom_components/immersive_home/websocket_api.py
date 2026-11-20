"""Home Assistant websocket API."""

from __future__ import annotations

from typing import Any

import voluptuous as vol

from homeassistant.components import websocket_api
from homeassistant.core import HomeAssistant, callback
from homeassistant.helpers.dispatcher import async_dispatcher_connect

from .const import DOMAIN, SIGNAL_FLOOR_PLAN_UPDATED
from .floor_plan import FloorPlan
from .hub import REGISTRATION_FIELDS, Hub

# Only the outline is checked, the app owns the details (app/lib/utils/floor_plan.gd).
FLOOR_PLAN_SCHEMA = vol.Schema(
    {
        vol.Required("version"): int,
        vol.Required("rooms"): [dict],
        vol.Required("doors"): [dict],
        vol.Required("entities"): [dict],
    },
    extra=vol.ALLOW_EXTRA,
)

# Sent when no headset synced a floor plan yet.
NO_FLOOR_PLAN = {"floor_plan": None, "device_id": None, "updated_at": None}


@callback
def async_setup_commands(hass: HomeAssistant) -> None:
    """Set up the Immersive Home websocket API."""
    websocket_api.async_register_command(hass, handle_register)
    websocket_api.async_register_command(hass, handle_update)
    websocket_api.async_register_command(hass, handle_update_floor_plan)
    websocket_api.async_register_command(hass, handle_get_floor_plan)
    websocket_api.async_register_command(hass, handle_subscribe_floor_plan)


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


@websocket_api.websocket_command(
    {
        vol.Required("type"): "immersive_home/floor_plan/update",
        vol.Required("device_id"): str,
        vol.Required("floor_plan"): FLOOR_PLAN_SCHEMA,
    }
)
@callback
def handle_update_floor_plan(
    hass: HomeAssistant,
    connection: websocket_api.ActiveConnection,
    msg: dict[str, Any],
) -> None:
    """Replace the floor plan with the one of a headset."""

    hub: Hub = hass.data[DOMAIN]["hub"]

    if hub.get_device(msg["device_id"]) is None:
        connection.send_error(msg["id"], "device_not_found", "Device not found")
        return

    floor_plan: FloorPlan = hass.data[DOMAIN]["floor_plan"]
    floor_plan.async_set(msg["device_id"], msg["floor_plan"])

    connection.send_result(msg["id"], {"result": "success"})


@websocket_api.websocket_command(
    {
        vol.Required("type"): "immersive_home/floor_plan/get",
    }
)
@callback
def handle_get_floor_plan(
    hass: HomeAssistant,
    connection: websocket_api.ActiveConnection,
    msg: dict[str, Any],
) -> None:
    """Return the floor plan: {floor_plan, device_id, updated_at}."""

    floor_plan: FloorPlan = hass.data[DOMAIN]["floor_plan"]
    connection.send_result(msg["id"], floor_plan.data or NO_FLOOR_PLAN)


@websocket_api.websocket_command(
    {
        vol.Required("type"): "immersive_home/floor_plan/subscribe",
    }
)
@callback
def handle_subscribe_floor_plan(
    hass: HomeAssistant,
    connection: websocket_api.ActiveConnection,
    msg: dict[str, Any],
) -> None:
    """Send the floor plan now and each time a headset changes it."""

    floor_plan: FloorPlan = hass.data[DOMAIN]["floor_plan"]

    @callback
    def forward(data: dict[str, Any]) -> None:
        connection.send_message(websocket_api.event_message(msg["id"], data))

    connection.subscriptions[msg["id"]] = async_dispatcher_connect(
        hass, SIGNAL_FLOOR_PLAN_UPDATED, forward
    )
    connection.send_result(msg["id"])
    forward(floor_plan.data or NO_FLOOR_PLAN)
