"""Config flow for Immersive Home."""

from homeassistant.config_entries import ConfigFlow

from .const import DOMAIN


class ImmersiveHomeFlowHandler(ConfigFlow, domain=DOMAIN):
    """Handle a Mobile App config flow."""

    VERSION = 1

    async def async_step_user(self, user_input=None):
        """Handle a flow initialized by the user."""
        placeholders = {
            "apps_url": "https://www.home-assistant.io/integrations/immersive_home/#apps"
        }

        return self.async_abort(
            reason="install_app", description_placeholders=placeholders
        )

    async def async_step_registration(self, user_input=None):
        """Handle a flow initialized during registration."""

        if "device_id" in user_input:
            await self.async_set_unique_id(f"{user_input['device_id']}")

        return self.async_create_entry(title=user_input["name"], data=user_input)
