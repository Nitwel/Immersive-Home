extends Node

const HASS_API = preload ("hass.gd")
const Auth = preload ("./auth.gd")

signal on_connect()
signal on_disconnect()

signal on_packed_received(packet: Dictionary)

signal _try_connect(success: bool)

const LOG_SENDING := false
const LOG_RECEIVING := false

var socket := WebSocketPeer.new()
var packet_callbacks := CallbackMap.new()
var api: HASS_API
var auth: Auth

var request_timeout := 10.0 # in seconds
var connection_timeout := 10.0 # in seconds

var connecting := false
var connected := false
var url := ""
var id := 1

enum ConnectionError {
	OK = 0,
	INVALID_URL = 1,
	CONNECTION_FAILED = 2,
	TIMEOUT = 3,
	INVALID_TOKEN = 4
}

func _init(api: HASS_API):
	self.api = api
	auth = Auth.new(self)
	add_child(auth)

	# https://github.com/godotengine/godot/issues/84423
	# Otherwise the WebSocketPeer will crash when receiving large packets
	socket.set_inbound_buffer_size(pow(2, 23)) # ~8MB buffer

func start(url: String, token: String) -> ConnectionError:
	if url == "":
		return ConnectionError.INVALID_URL

	if socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		socket.close()

	if connecting or connected:
		return ConnectionError.OK

	connecting = true

	print("Connecting to %s" % url + "/api/websocket")
	var error = socket.connect_to_url(url + "/api/websocket", TLSOptions.client_unsafe())

	if error != OK:
		print("Error connecting to %s: %s" % [url, error])
		return ConnectionError.CONNECTION_FAILED

	set_process(true)

	error = await ProcessTools.timed_signal(_try_connect, connection_timeout)

	if error == Error.ERR_TIMEOUT:
		print("Failed to connect to %s: Exceeded %ss" % [url, connection_timeout])
		return ConnectionError.TIMEOUT

	error = await auth.authenticate(token)

	if error == Auth.AuthError.TIMEOUT:
		return ConnectionError.TIMEOUT
	elif error != Auth.AuthError.OK:
		return ConnectionError.INVALID_TOKEN

	connected = true
	on_connect.emit()
	return ConnectionError.OK

func _process(_delta):
	socket.poll()
	
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if connecting:
			connecting = false
			_try_connect.emit(Error.OK)

		while socket.get_available_packet_count():
			var packet = _decode_packet(socket.get_packet())
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

		print("WS connection closed with code: %s, reason: %s" % [code, reason])
		set_process(false)
		connecting = false
		connected = false
		on_disconnect.emit()

func handle_packet(packet: Dictionary):
	if LOG_RECEIVING: print("Received packet: %s" % str(packet).substr(0, 1000))

	on_packed_received.emit(packet)

	if packet.has("id"):
		packet_callbacks.call_key(int(packet.id), [packet])

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
		
		var timeout=get_tree().create_timer(request_timeout)

		timeout.timeout.connect(func():
			reject.call(Promise.Rejection.new("Request timed out"))
			if ignore_initial:
				packet_callbacks.remove(packet.id, fn)
			else:
				packet_callbacks.remove(packet.id, resolve)
		)
	)

	send_packet(packet)

	return await promise.settled

func send_raw(packet: PackedByteArray):
	if LOG_SENDING: print("Sending binary: %s" % packet.hex_encode())
	socket.send(packet)

func send_packet(packet: Dictionary, with_id:=false):
	if with_id:
		packet.id = id
		id += 1

	if LOG_SENDING: print("Sending packet: %s" % _encode_packet(packet))
	socket.send_text(_encode_packet(packet))

func _decode_packet(packet: PackedByteArray):
	return JSON.parse_string(packet.get_string_from_utf8())

func _encode_packet(packet: Dictionary):
	return JSON.stringify(packet)
