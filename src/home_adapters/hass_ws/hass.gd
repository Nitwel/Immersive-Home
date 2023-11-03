extends Node

var devices_template := FileAccess.get_file_as_string("res://src/home_adapters/hass/templates/devices.j2")
var socket := WebSocketPeer.new()
# in seconds
var request_timeout := 10.0

var url := "ws://192.168.33.33:8123/api/websocket"
var token := "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIzZjQ0ZGM2N2Y3YzY0MDc1OGZlMWI2ZjJlNmIxZjRkNSIsImlhdCI6MTY5ODAxMDcyOCwiZXhwIjoyMDEzMzcwNzI4fQ.K6ydLUC-4Q7BNIRCU1nWlI2s6sg9UCiOu-Lpedw2zJc"


var authenticated := false
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

func _process(delta):
	socket.poll()
	
	var state = socket.get_ready_state()
	print(state, "POLLING")
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			handle_packet(socket.get_packet())
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WS connection closed with code: %s, reason: %s" % [code, reason])
		handle_disconnect()

func handle_packet(raw_packet: PackedByteArray):
	var packet = decode_packet(raw_packet)

	print("Received packet: %s" % packet)

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
		packet_callbacks.call_key(packet.id, [packet])

func start_subscriptions():
	assert(authenticated, "Not authenticated")

	await send_request_packet({
		"type": "supported_features",
		"features": {
			"coalesce_messages": 1
		}
	})

	send_subscribe_packet({
		"type": "subscribe_entities"
	}, func(packet: Dictionary):
		if packet.type != "event":
			return

		if packet.event.has("a"):
			for entity in packet.event.a.keys():
				entities[entity] = packet.event.a[entity]
				entitiy_callbacks.call_key(entity, [entities[entity]])
			on_connect.emit()

		if packet.event.has("c"):
			for entity in packet.event.c.keys():
				if packet.event.c[entity].has("+"):
					entities[entity].merge(packet.event.c[entity]["+"])
					entitiy_callbacks.call_key(entity, [entities[entity]])
	)

func handle_disconnect():
	authenticated = false
	set_process(false)
	on_disconnect.emit()

func send_subscribe_packet(packet: Dictionary, callback: Callable):
	packet.id = id
	id += 1

	send_packet(packet)
	packet_callbacks.add(packet.id, callback)

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
	print("Sending packet: %s" % encode_packet(packet))
	socket.send_text(encode_packet(packet))

func decode_packet(packet: PackedByteArray):
	return JSON.parse_string(packet.get_string_from_utf8())

func encode_packet(packet: Dictionary):
	return JSON.stringify(packet)

func load_devices():
	pass

func get_state(entity: String):
	if !authenticated:
		await on_connect

	if entities.has(entity):
		return entities[entity]
	else:
		print(entities, entity)


func watch_state(entity: String, callback: Callable):
	if !authenticated:
		await on_connect

	entitiy_callbacks.add(entity, callback)


func set_state(entity: String, state: String, attributes: Dictionary = {}):
	assert(authenticated, "Not authenticated")

	var domain = entity.split(".")[0]
	var service =  entity.split(".")[1]

	return await send_request_packet({
		"type": "call_service",
		"domain": domain,
		"service": service,
		"service_data": attributes,
		"target": {
			"entity_id": entity
		}
	})

	
