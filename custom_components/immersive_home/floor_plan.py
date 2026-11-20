"""Persistent floor plan of the house, as synced by the headsets.

There is one floor plan for the whole house: the headset that changed its room
setup last replaces it. The format is documented in the app, in
app/lib/utils/floor_plan.gd: rooms, doors and entities in meters, in a frame
anchored to the house so the coordinates stay stable across sessions.
"""

from __future__ import annotations

from typing import Any

from homeassistant.core import HomeAssistant, callback
from homeassistant.helpers.dispatcher import async_dispatcher_send
from homeassistant.helpers.storage import Store
from homeassistant.util import dt as dt_util

from .const import DOMAIN, EVENT_FLOOR_PLAN_UPDATED, SIGNAL_FLOOR_PLAN_UPDATED

STORAGE_VERSION = 1
STORAGE_KEY = f"{DOMAIN}.floor_plan"


class FloorPlan:
    """Loads, stores and announces the floor plan."""

    def __init__(self, hass: HomeAssistant) -> None:
        self._hass = hass
        self._store: Store[dict[str, Any]] = Store(hass, STORAGE_VERSION, STORAGE_KEY)
        self._data: dict[str, Any] | None = None

    async def async_load(self) -> None:
        self._data = await self._store.async_load()

    @property
    def data(self) -> dict[str, Any] | None:
        """The stored floor plan with who sent it and when, or None if none was synced yet.

        {"floor_plan": {...}, "device_id": str, "updated_at": ISO time}
        """
        return self._data

    @callback
    def async_set(self, device_id: str, floor_plan: dict[str, Any]) -> None:
        """Replace the floor plan and tell everyone listening."""
        self._data = {
            "floor_plan": floor_plan,
            "device_id": device_id,
            "updated_at": dt_util.utcnow().isoformat(),
        }
        self._store.async_delay_save(lambda: self._data, 1)

        async_dispatcher_send(self._hass, SIGNAL_FLOOR_PLAN_UPDATED, self._data)
        # Only the metadata: events are recorded, the floor plan itself can be large.
        self._hass.bus.async_fire(
            EVENT_FLOOR_PLAN_UPDATED,
            {"device_id": device_id, "updated_at": self._data["updated_at"]},
        )
