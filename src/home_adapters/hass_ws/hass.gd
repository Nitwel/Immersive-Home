extends Node

var devices_template := FileAccess.get_file_as_string("res://src/home_adapters/hass/templates/devices.j2")
var socket := WebSocketPeer.new()
# in seconds
var request_timeout := 10.0

var url := "ws://192.168.33.33:8123/api/websocket"
var token := "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIzZjQ0ZGM2N2Y3YzY0MDc1OGZlMWI2ZjJlNmIxZjRkNSIsImlhdCI6MTY5ODAxMDcyOCwiZXhwIjoyMDEzMzcwNzI4fQ.K6ydLUC-4Q7BNIRCU1nWlI2s6sg9UCiOu-Lpedw2zJc"
var LOG_MESSAGES := false

var authenticated := false
var loading := true
var id := 1
var entities: Dictionary = {}

var entitiy_callbacks := CallbackMap.new()
var packet_callbacks := CallbackMap.new()

signal on_connect()
signal on_disconnect()

func _init(url := self.url, token := self.token):
	self.url = url
	self.token = token

	devices_template = devices_template.replace("\n", " ").replace("\t", "").replace("\r", " ").replace("\"", "\\\"")
	connect_ws()

func connect_ws():
	print("Connecting to %s" % self.url)
	socket.connect_to_url(self.url)

	# https://github.com/godotengine/godot/issues/84423
	# Otherwise the WebSocketPeer will crash when receiving large packets
	socket.set_inbound_buffer_size(65535 * 2)

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
		print("WS connection closed with code: %s, reason: %s" % [code, reason])
		handle_disconnect()

func handle_packet(packet: Dictionary):
	if LOG_MESSAGES: print("Received packet: %s" % packet)

	if packet.type == "auth_required":
		send_packet({
			"type": "auth",
			"access_token": self.token
		})

	elif packet.type == "auth_ok":
		authenticated = true
		start_subscriptions()
		
	elif packet.type == "auth_invalid":
		handle_disconnect()
	else:
		packet_callbacks.call_key(int(packet.id), [packet])

func start_subscriptions():
	assert(authenticated, "Not authenticated")

	# await send_request_packet({
	# 	"type": "supported_features",
	# 	"features": {
	# 		"coalesce_messages": 1
	# 	}
	# })

	# await send_request_packet({
	# 	"type": "subscribe_events",
	# 	"event_type": "state_changed"
	# })

	send_subscribe_packet({
		"type": "subscribe_entities"
	}, func(packet: Dictionary):
		if packet.type != "event":
			return

		if packet.event.has("a"):
			for entity in packet.event.a.keys():
				entities[entity] = {
					"state": packet.event.a[entity]["s"],
					"attributes": packet.event.a[entity]["a"]
				}
				entitiy_callbacks.call_key(entity, [entities[entity]])
			loading = false
			on_connect.emit()

		if packet.event.has("c"):
			for entity in packet.event.c.keys():
				if !entities.has(entity):
					continue

				if packet.event.c[entity].has("+"):
					if packet.event.c[entity]["+"].has("s"):
						entities[entity]["state"] = packet.event.c[entity]["+"]["s"]
					if packet.event.c[entity]["+"].has("a"):
						entities[entity]["attributes"].merge(packet.event.c[entity]["+"]["a"])
					entitiy_callbacks.call_key(entity, [entities[entity]])
	)

func handle_disconnect():
	authenticated = false
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


func send_request_packet(packet: Dictionary):
	packet.id = id
	id += 1

	send_packet(packet)

	var promise = Promise.new(func(resolve: Callable, reject: Callable):		
		packet_callbacks.add_once(packet.id, resolve)
		
		var timeout = Timer.new()
		timeout.set_wait_time(request_timeout)
		timeout.set_one_shot(true)
		timeout.timeout.connect(func():
			reject.call(Promise.Rejection.new("Request timed out"))
			packet_callbacks.remove(packet.id, resolve)
		)
		add_child(timeout)
		timeout.start()
	)

	return await promise.settled


func send_packet(packet: Dictionary):
	if LOG_MESSAGES || true: print("Sending packet: %s" % encode_packet(packet))
	socket.send_text(encode_packet(packet))

func decode_packet(packet: PackedByteArray):
	return JSON.parse_string(packet.get_string_from_utf8())

func encode_packet(packet: Dictionary):
	return JSON.stringify(packet)

func load_devices():
	if loading:
		await on_connect

	return entities

func get_state(entity: String):
	if loading:
		await on_connect

	if entities.has(entity):
		return entities[entity]
	return null


func watch_state(entity: String, callback: Callable):
	if loading:
		await on_connect

	entitiy_callbacks.add(entity, callback)


func set_state(entity: String, state: String, attributes: Dictionary = {}):
	assert(!loading, "Still loading")

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

	return await send_request_packet({
		"type": "call_service",
		"domain": domain,
		"service": service,
		"service_data": attributes,
		"target": {
			"entity_id": entity
		}
	})

	
