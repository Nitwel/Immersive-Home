extends Node

# MQTT client implementation in GDScript
# Loosely based on https://github.com/pycom/pycom-libraries/blob/master/lib/mqtt/mqtt.py
# and initial work by Alex J Lennon <ajlennon@dynamicdevices.co.uk>
# but then heavily rewritten to follow https://docs.oasis-open.org/mqtt/mqtt/v3.1.1/mqtt-v3.1.1.html

# mosquitto_sub -h test.mosquitto.org -v -t "metest/#"
# mosquitto_pub -h test.mosquitto.org -t "metest/retain" -m "retained message" -r

@export var client_id = ""
@export var verbose_level = 2  # 0 quiet, 1 connections and subscriptions, 2 all messages
@export var binarymessages = false
@export var pinginterval = 30

var socket = null
var sslsocket = null
var websocket = null

const BCM_NOCONNECTION = 0
const BCM_WAITING_WEBSOCKET_CONNECTION = 1
const BCM_WAITING_SOCKET_CONNECTION = 2
const BCM_WAITING_SSL_SOCKET_CONNECTION = 3
const BCM_FAILED_CONNECTION = 5
const BCM_WAITING_CONNMESSAGE = 10
const BCM_WAITING_CONNACK = 19
const BCM_CONNECTED = 20

var brokerconnectmode = BCM_NOCONNECTION

var regexbrokerurl = RegEx.new()

const DEFAULTBROKERPORT_TCP = 1883
const DEFAULTBROKERPORT_SSL = 8886
const DEFAULTBROKERPORT_WS = 8080
const DEFAULTBROKERPORT_WSS = 8081

const CP_PINGREQ = 0xc0
const CP_PINGRESP = 0xd0
const CP_CONNACK = 0x20
const CP_CONNECT = 0x10
const CP_PUBLISH = 0x30
const CP_SUBSCRIBE = 0x82
const CP_UNSUBSCRIBE = 0xa2
const CP_PUBREC = 0x40
const CP_SUBACK = 0x90
const CP_UNSUBACK = 0xb0

var pid = 0
var user = null
var pswd = null
var keepalive = 120
var lw_topic = null
var lw_msg = null
var lw_qos = 0
var lw_retain = false

signal received_message(topic, message)
signal broker_connected()
signal broker_disconnected()
signal broker_connection_failed()
signal publish_acknowledge(pid)

var receivedbuffer : PackedByteArray = PackedByteArray()

var common_name = null

func senddata(data):
	var E = 0
	if sslsocket != null:
		E = sslsocket.put_data(data)
	elif socket != null:
		E = socket.put_data(data)
	elif websocket != null:
		E = websocket.put_packet(data)
	if E != 0:
		print("bad senddata packet E=", E)
	
func receiveintobuffer():
	if sslsocket != null:
		var sslsocketstatus = sslsocket.get_status()
		if sslsocketstatus == StreamPeerTLS.STATUS_CONNECTED or sslsocketstatus == StreamPeerTLS.STATUS_HANDSHAKING:
			var E = sslsocket.poll()
			if E != 0:
				printerr("Socket poll error: ", E)
				return E
			var n = sslsocket.get_available_bytes()
			if n == -1:
				printerr("get_available_bytes returned -1")
				return FAILED
			if n != 0:
				assert (n > 0)
				var sv = sslsocket.get_data(n)
				assert (sv[0] == 0)  # error code
				receivedbuffer.append_array(sv[1])
				
	elif socket != null and socket.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		var E = socket.poll()
		if E != 0:
			printerr("Socket poll error: ", E)
			return E
		var n = socket.get_available_bytes()
		if n == -1:
			printerr("get_available_bytes returned -1")
			return FAILED
		if n != 0:
			assert (n > 0)
			var sv = socket.get_data(n)
			assert (sv[0] == 0)  # error code
			receivedbuffer.append_array(sv[1])
			
	elif websocket != null:
		websocket.poll()
		while websocket.get_available_packet_count() != 0:
			receivedbuffer.append_array(websocket.get_packet())
	
var pingticksnext0 = 0

func _process(delta):
	if brokerconnectmode == BCM_NOCONNECTION:
		pass
	elif brokerconnectmode == BCM_WAITING_WEBSOCKET_CONNECTION:
		websocket.poll()
		var websocketstate = websocket.get_ready_state()
		if websocketstate == WebSocketPeer.STATE_CLOSED:
			if verbose_level:
				print("WebSocket closed with code: %d, reason %s." % [websocket.get_close_code(), websocket.get_close_reason()])
			brokerconnectmode = BCM_FAILED_CONNECTION
			emit_signal("broker_connection_failed")
		elif websocketstate == WebSocketPeer.STATE_OPEN:
			brokerconnectmode = BCM_WAITING_CONNMESSAGE
			if verbose_level:
				print("Websocket connection now open")
			
	elif brokerconnectmode == BCM_WAITING_SOCKET_CONNECTION:
		socket.poll()
		var socketstatus = socket.get_status()
		if socketstatus == StreamPeerTCP.STATUS_ERROR:
			if verbose_level:
				print("TCP socket error")
			brokerconnectmode = BCM_FAILED_CONNECTION
			emit_signal("broker_connection_failed")
		if socketstatus == StreamPeerTCP.STATUS_CONNECTED:
			brokerconnectmode = BCM_WAITING_CONNMESSAGE

	elif brokerconnectmode == BCM_WAITING_SSL_SOCKET_CONNECTION:
		socket.poll()
		var socketstatus = socket.get_status()
		if socketstatus == StreamPeerTCP.STATUS_ERROR:
			if verbose_level:
				print("TCP socket error before SSL")
			brokerconnectmode = BCM_FAILED_CONNECTION
			emit_signal("broker_connection_failed")
		if socketstatus == StreamPeerTCP.STATUS_CONNECTED:
			if sslsocket == null:
				sslsocket = StreamPeerTLS.new()
				if verbose_level:
					print("Connecting socket to SSL with common_name=", common_name)
				var E3 = sslsocket.connect_to_stream(socket, common_name)
				if E3 != 0:
					print("bad sslsocket.connect_to_stream E=", E3)
					brokerconnectmode = BCM_FAILED_CONNECTION
					emit_signal("broker_connection_failed")
					sslsocket = null
			if sslsocket != null:
				sslsocket.poll()
				var sslsocketstatus = sslsocket.get_status()
				if sslsocketstatus == StreamPeerTLS.STATUS_CONNECTED:
					brokerconnectmode = BCM_WAITING_CONNMESSAGE
				elif sslsocketstatus >= StreamPeerTLS.STATUS_ERROR:
					print("bad sslsocket.connect_to_stream")
					emit_signal("broker_connection_failed")
				
	elif brokerconnectmode == BCM_WAITING_CONNMESSAGE:
		senddata(firstmessagetoserver())
		brokerconnectmode = BCM_WAITING_CONNACK
		
	elif brokerconnectmode == BCM_WAITING_CONNACK or brokerconnectmode == BCM_CONNECTED:
		receiveintobuffer()
		while wait_msg():
			pass
		if brokerconnectmode == BCM_CONNECTED and pingticksnext0 < Time.get_ticks_msec():
			pingreq()
			pingticksnext0 = Time.get_ticks_msec() + pinginterval*1000

	elif brokerconnectmode == BCM_FAILED_CONNECTION:
		cleanupsockets()

func _ready():
	regexbrokerurl.compile('^(tcp://|wss://|ws://|ssl://)?([^:\\s]+)(:\\d+)?(/\\S*)?$')
	if client_id == "":
		randomize()
		client_id = "rr%d" % randi()

func set_last_will(stopic, smsg, retain=false, qos=0):
	assert((0 <= qos) and (qos <= 2))
	assert(stopic)
	self.lw_topic = stopic.to_ascii_buffer()
	self.lw_msg = smsg if binarymessages else smsg.to_ascii_buffer()
	self.lw_qos = qos
	self.lw_retain = retain
	if verbose_level:
		print("LASTWILL%s topic=%s msg=%s" % [ " <retain>" if retain else "", stopic, smsg])

func set_user_pass(suser, spswd):
	if suser != null:
		self.user = suser.to_ascii_buffer()
		self.pswd = spswd.to_ascii_buffer()
	else:
		self.user = null
		self.pswd = null


static func encoderemaininglength(pkt, sz):
	assert(sz < 2097152)
	var i = 1
	while sz > 0x7f:
		pkt[i] = (sz & 0x7f) | 0x80
		sz >>= 7
		i += 1
		if i + 1 > len(pkt):
			pkt.append(0x00);
	pkt[i] = sz

static func encodeshortint(pkt, n):
	assert (n >= 0 and n < 65536)
	pkt.append((n >> 8) & 0xFF)
	pkt.append(n & 0xFF)

static func encodevarstr(pkt, bs):
	encodeshortint(pkt, len(bs))
	pkt.append_array(bs)

func firstmessagetoserver():
	var clean_session = true
	var pkt = PackedByteArray()
	pkt.append(CP_CONNECT);
	pkt.append(0x00);
	var sz = 10 + (2+len(self.client_id)) + \
			(2+len(self.user)+2+len(self.pswd) if self.user != null else 0) + \
			(2+len(self.lw_topic)+2+len(self.lw_msg) if self.lw_topic else 0)
	encoderemaininglength(pkt, sz)
	var remstartpos = len(pkt)
	encodevarstr(pkt, [0x4D, 0x51, 0x54, 0x54]); # "MQTT".to_ascii_buffer()
	var protocollevel = 0x04  # MQTT v3.1.1
	var connectflags = (0xC0 if self.user != null else 0) | \
					   (0x20 if self.lw_retain else 0) | \
					   (self.lw_qos << 3) | \
					   (0x04 if self.lw_topic else 0) | \
					   (0x02 if clean_session else 0)
	pkt.append(protocollevel);
	pkt.append(connectflags);
	encodeshortint(pkt, self.keepalive)
	encodevarstr(pkt, self.client_id.to_ascii_buffer())
	if self.lw_topic:
		encodevarstr(pkt, self.lw_topic)
		encodevarstr(pkt, self.lw_msg)
	if self.user != null:
		encodevarstr(pkt, self.user)
		encodevarstr(pkt, self.pswd)
	assert (len(pkt) - remstartpos == sz)
	return pkt

func cleanupsockets(retval=false):
	if verbose_level:
		print("cleanupsockets")
	if socket:
		if sslsocket:
			sslsocket = null
		socket.disconnect_from_host()
		socket = null
	else:
		assert (sslsocket == null)

	if websocket:
		websocket.close()
		websocket = null
	brokerconnectmode = BCM_NOCONNECTION
	return retval

func connect_to_broker(brokerurl):
	assert (brokerconnectmode == BCM_NOCONNECTION)
	var brokermatch = regexbrokerurl.search(brokerurl)
	if brokermatch == null:
		print("ERROR: unrecognized brokerurl pattern:", brokerurl)
		return cleanupsockets(false)
	var brokercomponents = brokermatch.strings
	var brokerprotocol = brokercomponents[1]
	var brokerserver = brokercomponents[2]
	var iswebsocket = (brokerprotocol == "ws://" or brokerprotocol == "wss://")
	var isssl = (brokerprotocol == "ssl://" or brokerprotocol == "wss://")
	var brokerport = ((DEFAULTBROKERPORT_WSS if isssl else DEFAULTBROKERPORT_WS) if iswebsocket else (DEFAULTBROKERPORT_SSL if isssl else DEFAULTBROKERPORT_TCP))
	if brokercomponents[3]:
		brokerport = int(brokercomponents[3].substr(1)) 
	var brokerpath = brokercomponents[4] if brokercomponents[4] else ""
	
	common_name = null	
	if iswebsocket:
		websocket = WebSocketPeer.new()
		websocket.supported_protocols = PackedStringArray(["mqttv3.1"])
		var websocketurl = ("wss://" if isssl else "ws://") + brokerserver + ":" + str(brokerport) + brokerpath
		if verbose_level:
			print("Connecting to websocketurl: ", websocketurl)
		var E = websocket.connect_to_url(websocketurl)
		if E != 0:
			print("ERROR: websocketclient.connect_to_url Err: ", E)
			return cleanupsockets(false)
		print("Websocket get_requested_url ", websocket.get_requested_url())
		brokerconnectmode = BCM_WAITING_WEBSOCKET_CONNECTION

	else:
		socket = StreamPeerTCP.new()
		if verbose_level:
			print("Connecting to %s:%s" % [brokerserver, brokerport])
		var E = socket.connect_to_host(brokerserver, brokerport)
		if E != 0:
			print("ERROR: socketclient.connect_to_url Err: ", E)
			return cleanupsockets(false)
		if isssl:
			brokerconnectmode = BCM_WAITING_SSL_SOCKET_CONNECTION
			common_name = brokerserver
		else:
			brokerconnectmode = BCM_WAITING_SOCKET_CONNECTION
		
	return true


func disconnect_from_server():
	if brokerconnectmode == BCM_CONNECTED:
		senddata(PackedByteArray([0xE0, 0x00]))
		emit_signal("broker_disconnected")
	cleanupsockets()
	

func publish(stopic, smsg, retain=false, qos=0):
	var msg = smsg.to_ascii_buffer() if not binarymessages else smsg
	var topic = stopic.to_ascii_buffer()
	
	var pkt = PackedByteArray()
	pkt.append(CP_PUBLISH | (2 if qos else 0) | (1 if retain else 0));
	pkt.append(0x00);
	var sz = 2 + len(topic) + len(msg) + (2 if qos > 0 else 0)
	encoderemaininglength(pkt, sz)
	var remstartpos = len(pkt)
	encodevarstr(pkt, topic)
	if qos > 0:
		pid += 1
		encodeshortint(pkt, pid)
	pkt.append_array(msg)
	assert (len(pkt) - remstartpos == sz)
	senddata(pkt)
	if verbose_level >= 2:
		print("CP_PUBLISH%s%s topic=%s msg=%s" % [ "[%d]"%pid if qos else "", " <retain>" if retain else "", stopic, smsg])
	return pid

func subscribe(stopic, qos=0):
	pid += 1
	var topic = stopic.to_ascii_buffer()
	var sz = 2 + 2 + len(topic) + 1
	var pkt = PackedByteArray()
	pkt.append(CP_SUBSCRIBE);
	pkt.append(0x00);
	encoderemaininglength(pkt, sz)
	var remstartpos = len(pkt)
	encodeshortint(pkt, pid)
	encodevarstr(pkt, topic)
	pkt.append(qos);
	assert (len(pkt) - remstartpos == sz)
	if verbose_level:
		print("SUBSCRIBE[%d] topic=%s" % [pid, stopic])
	senddata(pkt)

func pingreq():
	if verbose_level >= 2:
		print("PINGREQ")
	senddata(PackedByteArray([CP_PINGREQ, 0x00]))

func unsubscribe(stopic):
	pid += 1
	var topic = stopic.to_ascii_buffer()
	var sz = 2 + 2 + len(topic)
	var pkt = PackedByteArray()
	pkt.append(CP_UNSUBSCRIBE);
	pkt.append(0x00)
	encoderemaininglength(pkt, sz)
	var remstartpos = len(pkt)
	encodeshortint(pkt, pid)
	encodevarstr(pkt, topic)
	if verbose_level:
		print("UNSUBSCRIBE[%d] topic=%s" % [pid, stopic])
	assert (len(pkt) - remstartpos == sz)
	senddata(pkt)

func wait_msg():
	var n = receivedbuffer.size()
	if n < 2:
		return false
	var op = receivedbuffer[0]
	var i = 1
	var sz = receivedbuffer[i] & 0x7f
	while (receivedbuffer[i] & 0x80):
		i += 1
		if i == n:
			return false
		sz += (receivedbuffer[i] & 0x7f) << ((i-1)*7)
	i += 1
	if n < i + sz:
		return false
		
	if op == CP_PINGRESP:
		assert (sz == 0)
		if verbose_level >= 2:
			print("PINGRESP")
			
	elif op & 0xf0 == 0x30:
		var topic_len = (receivedbuffer[i]<<8) + receivedbuffer[i+1]
		var im = i + 2
		var topic = receivedbuffer.slice(im, im + topic_len).get_string_from_ascii()
		im += topic_len
		var pid1 = 0
		if op & 6:
			pid1 = (receivedbuffer[im]<<8) + receivedbuffer[im+1]
			im += 2
		var data = receivedbuffer.slice(im, i + sz)
		var msg = data if binarymessages else data.get_string_from_ascii()
		
		if verbose_level >= 2:
			print("received topic=", topic, " msg=", msg)
		emit_signal("received_message", topic, msg)
		
		if op & 6 == 2:
			senddata(PackedByteArray([0x40, 0x02, (pid1 >> 8), (pid1 & 0xFF)]))
		elif op & 6 == 4:
			assert(0)

	elif op == CP_CONNACK:
		assert (sz == 2)
		var retcode = receivedbuffer[i+1]
		if verbose_level:
			print("CONNACK ret=%02x" % retcode)
		if retcode == 0x00:
			brokerconnectmode = BCM_CONNECTED
			emit_signal("broker_connected")
		else:
			if verbose_level:
				print("Bad connection retcode=", retcode) # see https://docs.oasis-open.org/mqtt/mqtt/v3.1.1/mqtt-v3.1.1.html
			emit_signal("broker_connection_failed")

	elif op == CP_PUBREC:
		assert (sz == 2)
		var apid = (receivedbuffer[i]<<8) + receivedbuffer[i+1]
		if verbose_level >= 2:
			print("PUBACK[%d]" % apid)
		emit_signal("publish_acknowledgewait_msg", apid)

	elif op == CP_SUBACK:
		assert (sz == 3)
		var apid = (receivedbuffer[i]<<8) + receivedbuffer[i+1]
		if verbose_level:
			print("SUBACK[%d] ret=%02x" % [apid, receivedbuffer[i+2]])
		#if receivedbuffer[i+2] == 0x80:
		#	E = FAILED

	elif op == CP_UNSUBACK:
		assert (sz == 2)
		var apid = (receivedbuffer[i]<<8) + receivedbuffer[i+1]
		if verbose_level:
			print("UNSUBACK[%d]" % apid)

	else:
		if verbose_level:
			print("Unknown MQTT opcode op=%x" % op)

	trimreceivedbuffer(i + sz)
	return true

func trimreceivedbuffer(n):
	if n == receivedbuffer.size():
		receivedbuffer = PackedByteArray()
	else:
		assert (n <= receivedbuffer.size())
		receivedbuffer = receivedbuffer.slice(n)
