"""Config flow for Immersive Home."""

from homeassistant.config_entries import ConfigFlow

from .const import DOMAIN
from .hub import REGISTRATION_FIELDS


class ImmersiveHomeFlowHandler(ConfigFlow, domain=DOMAIN):
    """Handle an Immersive Home config flow."""

    VERSION = 1

    async def async_step_user(self, user_input=None):
        """Headsets add themselves when the app connects, there is nothing to set up by hand."""
        return self.async_abort(
            reason="install_app",
            description_placeholders={"docs_url": "https://docs.immersive-home.org"},
        )

    async def async_step_registration(self, user_input):
        """Handle a flow started by a headset registering over the websocket API."""
        registration = {key: user_input[key] for key in REGISTRATION_FIELDS}

        # A headset registers each time it connects. Keep a single entry per headset
        # and update it when the name or version changed.
        await self.async_set_unique_id(registration["device_id"])
        self._abort_if_unique_id_configured(updates=registration)

        return self.async_create_entry(title=registration["name"], data=registration)
