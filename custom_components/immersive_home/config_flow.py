"""Config flow for Immersive Home.

There are two kinds of config entries:

- The hub entry, created once by the user (or imported from the old
  `immersive_home:` YAML). It has no device. Home Assistant only loads an
  integration at startup when it has a config entry or YAML, and the headsets
  register through the websocket commands set up when it loads, so this entry
  is what makes the first registration possible.
- One entry per headset, created when the headset registers.
"""

from typing import Any

from homeassistant.config_entries import ConfigFlow, ConfigFlowResult

from .const import DOMAIN, HUB_UNIQUE_ID
from .hub import REGISTRATION_FIELDS

HUB_TITLE = "Immersive Home"


class ImmersiveHomeFlowHandler(ConfigFlow, domain=DOMAIN):
    """Handle an Immersive Home config flow."""

    VERSION = 1

    async def async_step_user(
        self, user_input: dict[str, Any] | None = None
    ) -> ConfigFlowResult:
        """Set up the integration, so headsets can add themselves when the app connects."""
        if self._hub_configured():
            return self.async_abort(
                reason="already_set_up",
                description_placeholders={"docs_url": "https://docs.immersive-home.org"},
            )

        if user_input is None:
            return self.async_show_form(
                step_id="user",
                description_placeholders={"docs_url": "https://docs.immersive-home.org"},
            )

        return await self._async_create_hub()

    async def async_step_import(self, import_data: dict[str, Any]) -> ConfigFlowResult:
        """Create the hub entry for installs that still have `immersive_home:` in YAML."""
        if self._hub_configured():
            return self.async_abort(
                reason="already_set_up",
                description_placeholders={"docs_url": "https://docs.immersive-home.org"},
            )

        return await self._async_create_hub()

    async def async_step_registration(self, user_input: dict[str, Any]) -> ConfigFlowResult:
        """Handle a flow started by a headset registering over the websocket API."""
        registration = {key: user_input[key] for key in REGISTRATION_FIELDS}

        # A headset registers each time it connects. Keep a single entry per headset
        # and update it when the name or version changed.
        await self.async_set_unique_id(registration["device_id"])
        self._abort_if_unique_id_configured(updates=registration)

        return self.async_create_entry(title=registration["name"], data=registration)

    def _hub_configured(self) -> bool:
        return any(
            entry.unique_id == HUB_UNIQUE_ID
            for entry in self._async_current_entries(include_ignore=False)
        )

    async def _async_create_hub(self) -> ConfigFlowResult:
        await self.async_set_unique_id(HUB_UNIQUE_ID)
        self._abort_if_unique_id_configured()
        return self.async_create_entry(title=HUB_TITLE, data={})
