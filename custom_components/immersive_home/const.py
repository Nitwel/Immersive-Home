"""Constants for the Immersive Home integration."""

DOMAIN = "immersive_home"
MANUFACTURER = "Immersive Home"

# Unique id of the integration's own config entry. It has no device, it only makes
# Home Assistant load the integration at startup, so headsets can register.
HUB_UNIQUE_ID = "hub"

# Where the integration serves its Lovelace cards.
FRONTEND_URL = f"/{DOMAIN}/frontend"
FLOOR_PLAN_CARD = "immersive-home-floor-plan-card.js"

# Fired on the event bus when a headset synced a new floor plan.
EVENT_FLOOR_PLAN_UPDATED = f"{DOMAIN}_floor_plan_updated"
# Dispatcher signal for the websocket subscriptions to the floor plan.
SIGNAL_FLOOR_PLAN_UPDATED = f"{DOMAIN}_floor_plan_updated"
