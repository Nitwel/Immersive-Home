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

func _init(url: String, token: String):
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

func has_connected():
	return connection.connected

func get_devices():
	var result = await connection.send_request_packet({
		"type": "render_template",
		"template": devices_template,
		"timeout": 3,
		"report_errors": true
	}, true)

	return result.payload.event.result

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

func set_state(entity: String, state: Variant, attributes: Dictionary={}):
	var domain = entity.split(".")[0]
	var service: String

	if domain == 'switch':
		if state == 'on':
			service = 'turn_on'
		elif state == 'off':
			service = 'turn_off'
	elif domain == 'light':
		if state == 'on':
			service = 'turn_on'
		elif state == 'off':
			service = 'turn_off'
	elif domain == 'media_player':
		if state == 'play':
			service = 'media_play'
		elif state == "pause":
			service = "media_pause"
		elif state == "next":
			service = "media_next_track"
		elif state == "previous":
			service = "media_previous_track"
		elif state == "volume":
			service = "volume_set"
	elif domain == 'button':
		if state == 'pressed':
			service = 'press'
	elif domain == 'number':
		service = 'set_value'
		attributes["value"] = state
	elif domain == 'timer':
		if state == 'start':
			service = 'start'
		elif state == 'cancel':
			service = 'cancel'
		elif state == 'pause':
			service = 'pause'

	if service == null:
		return null

	return await connection.send_request_packet({
		"type": "call_service",
		"domain": domain,
		"service": service,
		"service_data": attributes,
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

func get_history(entity_id, start, interval, end=null):
	return await history_handler.get_history(entity_id, start, interval, end)