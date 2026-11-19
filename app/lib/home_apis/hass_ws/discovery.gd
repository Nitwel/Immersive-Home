extends RefCounted
## Finds Home Assistant installs on the local network using mDNS (zeroconf).
##
## Home Assistant announces itself as [code]_home-assistant._tcp.local[/code].
## Queries are sent from a random port, which makes them "legacy unicast" queries
## (RFC 6762, section 6.7): responders answer straight to that port. So no multicast
## group has to be joined, which would need a multicast lock on Android.

const SetupCode = preload ("./setup_code.gd")

const SERVICE = "_home-assistant._tcp.local"
const MDNS_ADDRESS = "224.0.0.251"
const MDNS_PORT = 5353
## Milliseconds between repeated queries, as UDP packets can get lost.
const QUERY_INTERVAL = 600

const TYPE_A = 1
const TYPE_PTR = 12
const TYPE_TXT = 16
const TYPE_SRV = 33
const CLASS_IN = 1

## Searches the network for [param timeout] seconds and returns the installs found as
## [code]{"name": String, "url": String, "version": String, "uuid": String}[/code],
## where [code]url[/code] is the websocket URL expected by the hass_ws adapter.
static func discover(tree: SceneTree, timeout: float = 2.0) -> Array[Dictionary]:
	var udp = PacketPeerUDP.new()

	if udp.bind(0, "0.0.0.0") != OK:
		push_warning("Home Assistant discovery: could not open a UDP socket")
		return []

	udp.set_dest_address(MDNS_ADDRESS, MDNS_PORT)

	var records: Array[Dictionary] = []
	var start = Time.get_ticks_msec()
	var next_query = start

	while Time.get_ticks_msec() - start < timeout * 1000:
		if Time.get_ticks_msec() >= next_query:
			next_query += QUERY_INTERVAL
			udp.put_packet(_build_query(_missing_questions(records)))

		while udp.get_available_packet_count() > 0:
			records.append_array(_parse_packet(udp.get_packet()))

		await tree.process_frame

	udp.close()

	return _collect_installs(records)

## Asks for the service first, then for the records of found instances that were not
## included in the answers so far.
static func _missing_questions(records: Array[Dictionary]) -> Array:
	var questions = [[SERVICE, TYPE_PTR]]

	for instance in _find(records, TYPE_PTR, SERVICE):
		if _find(records, TYPE_SRV, instance.target).is_empty():
			questions.append([instance.target, TYPE_SRV])
		if _find(records, TYPE_TXT, instance.target).is_empty():
			questions.append([instance.target, TYPE_TXT])

	for service in _find(records, TYPE_SRV):
		if _find(records, TYPE_A, service.target).is_empty():
			questions.append([service.target, TYPE_A])

	return questions

static func _collect_installs(records: Array[Dictionary]) -> Array[Dictionary]:
	var installs: Array[Dictionary] = []
	var seen = {}

	for pointer in _find(records, TYPE_PTR, SERVICE):
		var instance: String = pointer.target
		var srv_records = _find(records, TYPE_SRV, instance)
		var txt_records = _find(records, TYPE_TXT, instance)
		var properties: Dictionary = txt_records[0].properties if txt_records.size() > 0 else {}

		var announced_url = properties.get("internal_url", "")
		if announced_url == "":
			announced_url = properties.get("base_url", "")

		var url = ""

		if srv_records.size() > 0:
			var srv = srv_records[0]
			var a_records = _find(records, TYPE_A, srv.target)
			var secure = announced_url.begins_with("https://")

			# The IP is preferred over the announced hostname, as .local names
			# can't be resolved everywhere. TLS isn't verified when connecting anyway.
			if a_records.size() > 0:
				url = "%s://%s:%d" % ["wss" if secure else "ws", a_records[0].address, srv.port]

		if url == ""&&announced_url != "":
			url = SetupCode.to_websocket_url(announced_url)

		if url == ""&&srv_records.size() > 0:
			url = "ws://%s:%d" % [srv_records[0].target, srv_records[0].port]

		var key = properties.get("uuid", url)
		if url == ""||seen.has(key):
			continue
		seen[key] = true

		installs.append({
			"name": properties.get("location_name", pointer.original_target.get_slice(".", 0)),
			"url": url,
			"version": properties.get("version", ""),
			"uuid": properties.get("uuid", ""),
		})

	return installs

static func _find(records: Array[Dictionary], type: int, name: String="") -> Array[Dictionary]:
	return records.filter(func(record): return record.type == type&&(name == ""||record.name == name))

static func _build_query(questions: Array) -> PackedByteArray:
	var packet = PackedByteArray()
	# Header: id, flags, question count, answer, authority and additional record counts.
	for value in [0, 0, questions.size(), 0, 0, 0]:
		_append_u16(packet, value)

	for question in questions:
		for label in question[0].split("."):
			var bytes = label.to_utf8_buffer()
			packet.append(bytes.size())
			packet.append_array(bytes)
		packet.append(0)
		_append_u16(packet, question[1])
		_append_u16(packet, CLASS_IN)

	return packet

static func _parse_packet(data: PackedByteArray) -> Array[Dictionary]:
	var records: Array[Dictionary] = []

	if data.size() < 12:
		return records

	var question_count = _read_u16(data, 4)
	var record_count = _read_u16(data, 6) + _read_u16(data, 8) + _read_u16(data, 10)
	var offset = 12

	for i in range(question_count):
		var question = _read_name(data, offset)
		if question.is_empty():
			return records
		offset = question.end + 4

	for i in range(record_count):
		var name = _read_name(data, offset)
		if name.is_empty()||name.end + 10 > data.size():
			break

		var type = _read_u16(data, name.end)
		var data_length = _read_u16(data, name.end + 8)
		var data_start = name.end + 10
		offset = data_start + data_length

		if offset > data.size():
			break

		var record = {"type": type, "name": name.name.to_lower()}

		match type:
			TYPE_PTR:
				var target = _read_name(data, data_start)
				if target.is_empty():
					continue
				record.target = target.name.to_lower()
				record.original_target = target.name
			TYPE_SRV:
				var target = _read_name(data, data_start + 6)
				if data_length < 7||target.is_empty():
					continue
				record.port = _read_u16(data, data_start + 4)
				record.target = target.name.to_lower()
			TYPE_TXT:
				record.properties = _read_txt(data.slice(data_start, offset))
			TYPE_A:
				if data_length != 4:
					continue
				record.address = "%d.%d.%d.%d" % [data[data_start], data[data_start + 1], data[data_start + 2], data[data_start + 3]]
			_:
				continue

		records.append(record)

	return records

## Reads a (possibly compressed) domain name. Returns [code]{"name": String, "end": int}[/code]
## where [code]end[/code] is the offset right after the name, or an empty dictionary if it's malformed.
static func _read_name(data: PackedByteArray, offset: int) -> Dictionary:
	var labels = PackedStringArray()
	var end = -1
	var jumps = 0

	while true:
		if offset >= data.size():
			return {}

		var length = data[offset]

		if length == 0:
			if end == -1:
				end = offset + 1
			break

		if (length & 0xC0) == 0xC0:
			if offset + 1 >= data.size()||jumps > 32:
				return {}
			if end == -1:
				end = offset + 2
			offset = ((length & 0x3F) << 8)|data[offset + 1]
			jumps += 1
			continue

		if offset + 1 + length > data.size():
			return {}

		labels.append(data.slice(offset + 1, offset + 1 + length).get_string_from_utf8())
		offset += 1 + length

	return {"name": ".".join(labels), "end": end}

static func _read_txt(data: PackedByteArray) -> Dictionary:
	var properties = {}
	var offset = 0

	while offset < data.size():
		var length = data[offset]
		var entry = data.slice(offset + 1, offset + 1 + length).get_string_from_utf8()
		offset += 1 + length

		var key = entry.get_slice("=", 0)
		if key != "":
			properties[key] = entry.substr(key.length() + 1)

	return properties

static func _read_u16(data: PackedByteArray, offset: int) -> int:
	return (data[offset] << 8)|data[offset + 1]

static func _append_u16(packet: PackedByteArray, value: int):
	packet.append((value >> 8) & 0xFF)
	packet.append(value & 0xFF)
