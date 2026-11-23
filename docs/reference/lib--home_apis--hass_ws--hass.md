# Hass
**Inherits:** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

## Properties

| Name                                             | Type                                                                               | Default |
| ------------------------------------------------ | ---------------------------------------------------------------------------------- | ------- |
| [assist_handler](#prop-assist-handler)           | [Assist](/reference/lib--home_apis--hass_ws--handlers--assist.html)                |         |
| [connection](#prop-connection)                   | [Connection](/reference/lib--home_apis--hass_ws--connection.html)                  |         |
| [devices_template](#prop-devices-template)       | [String](https://docs.godotengine.org/en/stable/classes/class_string.html)         |         |
| [entities](#prop-entities)                       | [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | `{}`    |
| [entitiy_callbacks](#prop-entitiy-callbacks)     | [CallbackMap](/reference/CallbackMap.html)                                         |         |
| [history_handler](#prop-history-handler)         | [History](/reference/lib--home_apis--hass_ws--handlers--history.html)              |         |
| [integration_handler](#prop-integration-handler) | [Integration](/reference/lib--home_apis--hass_ws--handlers--integration.html)      |         |
| [token](#prop-token)                             | [String](https://docs.godotengine.org/en/stable/classes/class_string.html)         |         |
| [url](#prop-url)                                 | [String](https://docs.godotengine.org/en/stable/classes/class_string.html)         |         |

## Methods

| Returns                                                                            | Name                                                                                                                                                                                                                                                                                                                                                                                             |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)           | [_devices_error](#-devices-error) ( reason: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                                                                                                                                                                                         |
| void                                                                               | [_init](#-init) ( url: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), token: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                                                                                                                           |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [get_device](#get-device) ( id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                                                                                                                                                                                                     |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [get_devices](#get-devices) (  )                                                                                                                                                                                                                                                                                                                                                                 |
| [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)           | [get_entity_ids](#get-entity-ids) ( domains: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) )                                                                                                                                                                                                                                                                          |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [get_history](#get-history) ( entity_id: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), start: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), interval: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), end: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) = `null` ) |
| [String](https://docs.godotengine.org/en/stable/classes/class_string.html)         | [get_http_url](#get-http-url) (  )                                                                                                                                                                                                                                                                                                                                                               |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [get_state](#get-state) ( entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                                                                                                                                                                                                   |
| [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | [get_state_history](#get-state-history) ( entity_ids: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html), start: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), end: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) = `null` )                                                                                  |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [get_todo_items](#get-todo-items) ( entity_id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                                                                                                                                                                                      |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [get_voice_assistant](#get-voice-assistant) (  )                                                                                                                                                                                                                                                                                                                                                 |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [has_connected](#has-connected) (  )                                                                                                                                                                                                                                                                                                                                                             |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [has_integration](#has-integration) (  )                                                                                                                                                                                                                                                                                                                                                         |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [set_state](#set-state) ( entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html), attributes: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) = `{}` )                                                                                       |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [start_subscriptions](#start-subscriptions) (  )                                                                                                                                                                                                                                                                                                                                                 |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [unwatch_owner](#unwatch-owner) ( target: [Object](https://docs.godotengine.org/en/stable/classes/class_object.html) )                                                                                                                                                                                                                                                                           |
| [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)             | [update_floor_plan](#update-floor-plan) ( floor_plan: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) )                                                                                                                                                                                                                                                       |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [update_room](#update-room) ( room: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) )                                                                                                                                                                                                                                                                                 |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)       | [watch_state](#watch-state) ( entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), callback: [Callable](https://docs.godotengine.org/en/stable/classes/class_callable.html) )                                                                                                                                                                                     |

## Signals

### on_connect ( ) {#on-connect}

No description provided yet.

### on_disconnect ( ) {#on-disconnect}

No description provided yet.

### on_integration_ready ( ) {#on-integration-ready}

Emitted once Home Assistant confirmed the Immersive Home integration is installed

## Constants

### AssistHandler = `<Object>` {#const-AssistHandler}

No description provided yet.

### Connection = `<Object>` {#const-Connection}

No description provided yet.

### HistoryHandler = `<Object>` {#const-HistoryHandler}

No description provided yet.

### IntegrationHandler = `<Object>` {#const-IntegrationHandler}

No description provided yet.

### SERVICES = `{"alarm_control_panel": {"arm_away": "alarm_arm_away", "arm_custom_bypass": "alarm_arm_custom_bypass", "arm_home": "alarm_arm_home", "arm_night": "alarm_arm_night", "arm_vacation": "alarm_arm_vacation", "disarm": "alarm_disarm"}, "automation": {"off": "turn_off", "on": "turn_on"}, "button": {"pressed": "press"}, "climate": {"hvac_mode": "set_hvac_mode", "temperature": "set_temperature"}, "cover": {"close": "close_cover", "open": "open_cover", "position": "set_cover_position", "stop": "stop_cover"}, "fan": {"off": "turn_off", "on": "turn_on", "oscillate": "oscillate", "percentage": "set_percentage", "preset_mode": "set_preset_mode"}, "humidifier": {"humidity": "set_humidity", "mode": "set_mode", "off": "turn_off", "on": "turn_on"}, "input_boolean": {"off": "turn_off", "on": "turn_on"}, "input_button": {"pressed": "press"}, "light": {"off": "turn_off", "on": "turn_on"}, "lock": {"lock": "lock", "open": "open", "unlock": "unlock"}, "media_player": {"next": "media_next_track", "pause": "media_pause", "play": "media_play", "previous": "media_previous_track", "volume": "volume_set"}, "scene": {"pressed": "turn_on"}, "script": {"pressed": "turn_on"}, "switch": {"off": "turn_off", "on": "turn_on"}, "timer": {"cancel": "cancel", "pause": "pause", "start": "start"}, "update": {"install": "install", "skip": "skip"}, "vacuum": {"clean_spot": "clean_spot", "fan_speed": "set_fan_speed", "locate": "locate", "pause": "pause", "return_to_base": "return_to_base", "start": "start", "stop": "stop"}, "water_heater": {"off": "turn_off", "on": "turn_on", "operation_mode": "set_operation_mode", "temperature": "set_temperature"}}` {#const-SERVICES}

Maps the state an entity widget asks for to the Home Assistant service that produces it. Each domain maps a requested state to a service name.

### VALUE_SERVICES = `{"date": ["set_value", "date"], "datetime": ["set_value", "datetime"], "input_number": ["set_value", "value"], "input_select": ["select_option", "option"], "input_text": ["set_value", "value"], "number": ["set_value", "value"], "select": ["select_option", "option"], "text": ["set_value", "value"], "time": ["set_value", "time"]}` {#const-VALUE-SERVICES}

Domains whose widgets send the new value itself as the state. The value is passed to the service in this field.

## Property Descriptions

### assist_handler: [Assist](/reference/lib--home_apis--hass_ws--handlers--assist.html) {#prop-assist-handler}

No description provided yet.

### connection: [Connection](/reference/lib--home_apis--hass_ws--connection.html) {#prop-connection}

No description provided yet.

### devices_template: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#prop-devices-template}

No description provided yet.

### entities: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#prop-entities}

No description provided yet.

### entitiy_callbacks: [CallbackMap](/reference/CallbackMap.html) {#prop-entitiy-callbacks}

No description provided yet.

### history_handler: [History](/reference/lib--home_apis--hass_ws--handlers--history.html) {#prop-history-handler}

No description provided yet.

### integration_handler: [Integration](/reference/lib--home_apis--hass_ws--handlers--integration.html) {#prop-integration-handler}

No description provided yet.

### token: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#prop-token}

No description provided yet.

### url: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#prop-url}

No description provided yet.

## Method Descriptions

### _devices_error (reason: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) {#-devices-error}

No description provided yet.

### _init (url: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , token: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> void {#-init}

No description provided yet.

### get_device (id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#get-device}

No description provided yet.

### get_devices ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#get-devices}

No description provided yet.

### get_entity_ids (domains: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)  ) -> [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) {#get-entity-ids}

Ids of all known entities in `domains`.

### get_history (entity_id: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , start: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , interval: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , end: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) = `null`  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#get-history}

No description provided yet.

### get_http_url ( ) -> [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#get-http-url}

Converts the websocket URL (ws:// or wss://) to its HTTP(S) equivalent without a trailing slash.

### get_state (entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#get-state}

No description provided yet.

### get_state_history (entity_ids: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html) , start: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , end: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) = `null`  ) -> [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) {#get-state-history}

No description provided yet.

### get_todo_items (entity_id: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#get-todo-items}

No description provided yet.

### get_voice_assistant ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#get-voice-assistant}

No description provided yet.

### has_connected ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#has-connected}

No description provided yet.

### has_integration ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#has-integration}

No description provided yet.

### set_state (entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , state: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) , attributes: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) = `{}`  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#set-state}

No description provided yet.

### start_subscriptions ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#start-subscriptions}

No description provided yet.

### unwatch_owner (target: [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#unwatch-owner}

Stops all state watches whose callback belongs to `target`.

### update_floor_plan (floor_plan: [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)  ) -> [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#update-floor-plan}

Sends the floor plan (see floor_plan.gd) to the integration, returns true if it was stored.

### update_room (room: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#update-room}

No description provided yet.

### watch_state (entity: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , callback: [Callable](https://docs.godotengine.org/en/stable/classes/class_callable.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#watch-state}

No description provided yet.
