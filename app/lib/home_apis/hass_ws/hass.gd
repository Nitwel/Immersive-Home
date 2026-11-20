extends Node

const IntegrationHandler = preload ("./handlers/integration.gd")
const AssistHandler = preload ("./handlers/assist.gd")
const HistoryHandler = preload ("./handlers/history.gd")
const Connection = preload ("./connection.gd")

signal on_connect()
signal on_disconnect()

var devices_template := FileAccess.get_file_as_string("res://lib/home_apis/hass_ws/templates/devices.j2")

var entities: Dictionary = {}
var entitiy_callbacks := CallbackMap.new()

var connection: Connection
var integration_handler: IntegrationHandler
var assist_handler: AssistHandler
var history_handler: HistoryHandler

var url: String
var token: String

func _init(url: String, token: String):
	self.url = url
	self.token = token

	connection = Connection.new(self)
	add_child(connection)

	connection.on_disconnect.connect(func():
		on_disconnect.emit()
	)

	var error = await connection.start(url, token)

	if error != Connection.ConnectionError.OK:
		print("Error starting connection: ", error)
		return

	integration_handler = IntegrationHandler.new(self)
	assist_handler = AssistHandler.new(self)
	history_handler = HistoryHandler.new(self)

	start_subscriptions()

	devices_template = devices_template.replace("\n", " ").replace("\t", "").replace("\r", " ")

func start_subscriptions():
	connection.send_subscribe_packet({
		"type": "subscribe_entities"
	}, func(packet: Dictionary):
		if packet.type != "event":
			return

		if packet.event.has("a"):
			for entity in packet.event.a.keys():
				entities[entity]={
					"state": packet.event.a[entity]["s"],
					"attributes": packet.event.a[entity]["a"]
				}
				entitiy_callbacks.call_key(entity, [entities[entity]])
			on_connect.emit()

		if packet.event.has("c"):
			for entity in packet.event.c.keys():
				if !entities.has(entity):
					continue

				if packet.event.c[entity].has("+"):
					if packet.event.c[entity]["+"].has("s"):
						entities[entity]["state"]=packet.event.c[entity]["+"]["s"]
					if packet.event.c[entity]["+"].has("a"):
						entities[entity]["attributes"].merge(packet.event.c[entity]["+"]["a"], true)
					entitiy_callbacks.call_key(entity, [entities[entity]])
	)

## Converts the websocket URL (ws:// or wss://) to its HTTP(S) equivalent without a trailing slash.
func get_http_url() -> String:
	var base = url.strip_edges().rstrip("/")
	var lower = base.to_lower()

	if lower.begins_with("wss://"):
		return "https://" + base.substr(6)
	if lower.begins_with("ws://"):
		return "http://" + base.substr(5)

	return base

func has_connected():
	return connection.connected

func get_devices():
	var result = await connection.send_request_packet({
		"type": "render_template",
		"template": devices_template,
		"timeout": 3,
		"report_errors": true
	}, true)

	# With report_errors, template warnings and errors arrive as an event without a result
	var event = result.payload.event
	if !event.has("result"):
		push_error("Home Assistant could not render the devices template: %s" % event.get("error", event))
		return []

	return event.result

func get_device(id: String):
	pass

func get_state(entity: String):
	if entities.has(entity):
		return entities[entity]
	return null

func watch_state(entity: String, callback: Callable):
	entitiy_callbacks.add(entity, callback)

	return func():
		entitiy_callbacks.remove(entity, callback)

## Stops all state watches whose callback belongs to [param target].
func unwatch_owner(target: Object):
	entitiy_callbacks.remove_owner(target)

## Maps the state an entity widget asks for to the Home Assistant service that
## produces it. Each domain maps a requested state to a service name.
const SERVICES = {
	"switch": {"on": "turn_on", "off": "turn_off"},
	"input_boolean": {"on": "turn_on", "off": "turn_off"},
	"automation": {"on": "turn_on", "off": "turn_off"},
	"light": {"on": "turn_on", "off": "turn_off"},
	"media_player": {"play": "media_play", "pause": "media_pause", "next": "media_next_track",
		"previous": "media_previous_track", "volume": "volume_set"},
	"button": {"pressed": "press"},
	"input_button": {"pressed": "press"},
	"scene": {"pressed": "turn_on"},
	"script": {"pressed": "turn_on"},
	"timer": {"start": "start", "cancel": "cancel", "pause": "pause"},
	"climate": {"temperature": "set_temperature", "hvac_mode": "set_hvac_mode"},
	"lock": {"lock": "lock", "unlock": "unlock", "open": "open"},
	"cover": {"open": "open_cover", "close": "close_cover", "stop": "stop_cover", "position": "set_cover_position"},
	"fan": {"on": "turn_on", "off": "turn_off", "percentage": "set_percentage", "preset_mode": "set_preset_mode",
		"oscillate": "oscillate"},
	"vacuum": {"start": "start", "pause": "pause", "stop": "stop", "return_to_base": "return_to_base",
		"locate": "locate", "clean_spot": "clean_spot", "fan_speed": "set_fan_speed"},
	"alarm_control_panel": {"disarm": "alarm_disarm", "arm_home": "alarm_arm_home", "arm_away": "alarm_arm_away",
		"arm_night": "alarm_arm_night", "arm_vacation": "alarm_arm_vacation", "arm_custom_bypass": "alarm_arm_custom_bypass"},
	"humidifier": {"on": "turn_on", "off": "turn_off", "humidity": "set_humidity", "mode": "set_mode"},
	"water_heater": {"on": "turn_on", "off": "turn_off", "temperature": "set_temperature",
		"operation_mode": "set_operation_mode"},
	"update": {"install": "install", "skip": "skip"},
}

## Domains whose widgets send the new value itself as the state. The value is passed
## to the service in this field.
const VALUE_SERVICES = {
	"number": ["set_value", "value"],
	"input_number": ["set_value", "value"],
	"select": ["select_option", "option"],
	"input_select": ["select_option", "option"],
	"text": ["set_value", "value"],
	"input_text": ["set_value", "value"],
	"date": ["set_value", "date"],
	"time": ["set_value", "time"],
	"datetime": ["set_value", "datetime"],
}

func set_state(entity: String, state: Variant, attributes: Dictionary={}):
	var domain = entity.split(".")[0]
	var service := ""
	var service_data = attributes.duplicate()

	if VALUE_SERVICES.has(domain):
		service = VALUE_SERVICES[domain][0]
		service_data[VALUE_SERVICES[domain][1]] = state
	elif SERVICES.has(domain):
		service = SERVICES[domain].get(str(state), "")

	if service == "":
		push_warning("No Home Assistant service for %s -> %s" % [entity, state])
		return null

	return await connection.send_request_packet({
		"type": "call_service",
		"domain": domain,
		"service": service,
		"service_data": service_data,
		"target": {
			"entity_id": entity
		}
	})

func has_integration():
	return integration_handler.integration_exists

func update_room(room: String):
	var response = await connection.send_request_packet({
		"type": "immersive_home/update",
		"device_id": OS.get_unique_id(),
		"room": room
	})

	if response.status == Promise.Status.RESOLVED:
		pass

func get_voice_assistant():
	return assist_handler

func get_todo_items(entity_id: String):
	var response = await connection.send_request_packet({
		"type": "todo/item/list",
		"entity_id": entity_id,
	})

	if response.status != Promise.Status.RESOLVED||response.payload.get("success") != true:
		return []

	var result = response.payload.get("result")
	return result.get("items", []) if result is Dictionary else []

func get_history(entity_id, start, interval, end=null):
	return await history_handler.get_history(entity_id, start, interval, end)