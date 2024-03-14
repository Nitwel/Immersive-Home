extends Node

const AuthHandler = preload ("./handlers/auth.gd")
const IntegrationHandler = preload ("./handlers/integration.gd")
const AssistHandler = preload ("./handlers/assist.gd")

signal on_connect()
signal on_disconnect()
var connected := false

var devices_template := FileAccess.get_file_as_string("res://lib/home_apis/hass_ws/templates/devices.j2")
var socket := WebSocketPeer.new()
# in seconds
var request_timeout := 10.0

# var url := "wss://8ybjhqcinfcdyvzu.myfritz.net:8123/api/websocket"
var url := ""
var token := ""

var LOG_MESSAGES := false

var id := 1
var entities: Dictionary = {}
var entitiy_callbacks := CallbackMap.new()
var packet_callbacks := CallbackMap.new()

var auth_handler: AuthHandler
var integration_handler: IntegrationHandler
var assist_handler: AssistHandler

func _init(url:=self.url, token:=self.token):
	self.url = url
	self.token = token

	auth_handler = AuthHandler.new(self, url, token)
	integration_handler = IntegrationHandler.new(self)
	assist_handler = AssistHandler.new(self)

	devices_template = devices_template.replace("\n", " ").replace("\t", "").replace("\r", " ")
	connect_ws()

	auth_handler.on_authenticated.connect(func():
		start_subscriptions()
	)

func connect_ws():
	if url == ""||token == "":
		return

	print("Connecting to %s" % url + "/api/websocket")
	socket.connect_to_url(url + "/api/websocket")
	set_process(true)

	# https://github.com/godotengine/godot/issues/84423
	# Otherwise the WebSocketPeer will crash when receiving large packets
	socket.set_inbound_buffer_size(pow(2, 23)) # ~8MB buffer

func _process(delta):
	socket.poll()
	
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var packet = decode_packet(socket.get_packet())
			if typeof(packet) == TYPE_DICTIONARY:
				handle_packet(packet)
			elif typeof(packet) == TYPE_ARRAY:
				for p in packet:
					handle_packet(p)
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()

		if reason == "":
			reason = "Invalid URL"

		var message = "WS connection closed with code: %s, reason: %s" % [code, reason]
		EventSystem.notify(message, EventNotify.Type.DANGER)
		print(message)
		handle_disconnect()

func handle_packet(packet: Dictionary):
	if LOG_MESSAGES: print("Received packet: %s" % str(packet).substr(0, 1000))

	auth_handler.handle_message(packet)
	assist_handler.handle_message(packet)

	if packet.has("id"):
		packet_callbacks.call_key(int(packet.id), [packet])

func start_subscriptions():
	send_subscribe_packet({
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
			handle_connect()

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

func handle_connect():
	integration_handler.on_connect()
	assist_handler.on_connect()
	connected = true
	on_connect.emit()

func handle_disconnect():
	auth_handler.on_disconnect()
	set_process(false)
	on_disconnect.emit()

func send_subscribe_packet(packet: Dictionary, callback: Callable):
	packet.id = id
	id += 1

	packet_callbacks.add(packet.id, callback)
	send_packet(packet)

	return func():
		packet_callbacks.remove(packet.id, callback)
		send_packet({
			id: id,
			"type": packet.type.replace("subscribe", "unsubscribe"),
			"subscription": packet.id
		})
		id += 1

func send_request_packet(packet: Dictionary, ignore_initial:=false):
	packet.id = id
	id += 1

	var promise = Promise.new(func(resolve: Callable, reject: Callable):
		var fn: Callable

		if ignore_initial:
			fn=func(packet: Dictionary):
				if packet.type == "event":
					resolve.call(packet)
					packet_callbacks.remove(packet.id, fn)

			packet_callbacks.add(packet.id, fn)
		else:
			packet_callbacks.add_once(packet.id, resolve)
		
		var timeout=Timer.new()
		timeout.set_wait_time(request_timeout)
		timeout.set_one_shot(true)
		timeout.timeout.connect(func():
			reject.call(Promise.Rejection.new("Request timed out"))
			if ignore_initial:
				packet_callbacks.remove(packet.id, fn)
			else:
				packet_callbacks.remove(packet.id, resolve)
		)
		add_child(timeout)
		timeout.start()
	)

	send_packet(packet)

	return await promise.settled

func send_raw(packet: PackedByteArray):
	if LOG_MESSAGES: print("Sending binary: %s" % packet.hex_encode())
	socket.send(packet)

func send_packet(packet: Dictionary, with_id:=false):
	if with_id:
		packet.id = id
		id += 1

	if LOG_MESSAGES: print("Sending packet: %s" % encode_packet(packet))
	socket.send_text(encode_packet(packet))

func decode_packet(packet: PackedByteArray):
	return JSON.parse_string(packet.get_string_from_utf8())

func encode_packet(packet: Dictionary):
	return JSON.stringify(packet)

func has_connected():
	return connected

func get_devices():
	var result = await send_request_packet({
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

	if service == null:
		return null

	return await send_request_packet({
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
	var response = await send_request_packet({
		"type": "immersive_home/update",
		"device_id": OS.get_unique_id(),
		"room": room
	})

	if response.status == Promise.Status.RESOLVED:
		pass