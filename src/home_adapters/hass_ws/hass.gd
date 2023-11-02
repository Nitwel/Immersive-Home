extends Node

var devices_template = FileAccess.get_file_as_string("res://src/home_adapters/hass/templates/devices.j2")
var socket = WebSocketPeer.new()
# in seconds
var request_timeout: float = 10

var url: String = "ws://192.168.33.33:8123/api/websocket"
var token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIzZjQ0ZGM2N2Y3YzY0MDc1OGZlMWI2ZjJlNmIxZjRkNSIsImlhdCI6MTY5ODAxMDcyOCwiZXhwIjoyMDEzMzcwNzI4fQ.K6ydLUC-4Q7BNIRCU1nWlI2s6sg9UCiOu-Lpedw2zJc"


var authenticated: bool = false
var id = 1

signal packet_received(packet: Dictionary)

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
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			handle_packet(socket.get_packet())
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WS connection closed with code: %s, reason: %s" % [code, reason])
		authenticated = false
		set_process(false)

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
	elif packet.type == "auth_invalid":
		authenticated = false
		print("Authentication failed")
		set_process(false)
	else:
		packet_received.emit(packet)

	
func send_request_packet(packet: Dictionary):
	packet.id = id
	id += 1

	send_packet(packet)

	var promise = Promise.new(func(resolve: Callable, reject: Callable):
		var handle_packet = func(recieved_packet: Dictionary):
			print("Received packet in handler: %s" % recieved_packet)
			if packet.id == recieved_packet.id:
				print("same id")
				resolve.call(recieved_packet)
				packet_received.disconnect(handle_packet)
		
		packet_received.connect(handle_packet)
		
		var timeout = Timer.new()
		timeout.set_wait_time(request_timeout)
		timeout.set_one_shot(true)
		timeout.timeout.connect(func():
			reject.call(Promise.Rejection.new("Request timed out"))
			packet_received.disconnect(handle_packet)
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
	assert(authenticated, "Not authenticated")

	var result = await send_request_packet({
		"type": "get_states"
	})

	if result.status == Promise.Status.RESOLVED:
		return result.payload
	return null


func watch_state(entity: String, callback: Callable):
	assert(authenticated, "Not authenticated")


func set_state(entity: String, state: String, attributes: Dictionary = {}):
	assert(authenticated, "Not authenticated")

	
