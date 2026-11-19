extends RefCounted
## Reads Home Assistant connection settings from a scanned QR code.
##
## Supported contents:
## - A long-lived access token on its own
## - The address of the instance, e.g. [code]http://homeassistant.local:8123[/code]
##   or [code]192.168.0.10:8123[/code]. An [code]access_token[/code] or [code]token[/code]
##   query parameter is used as token.
## - JSON, e.g. [code]{"url": "http://homeassistant.local:8123", "token": "..."}[/code]

const DEFAULT_PORT = 8123

## Returns [code]{"url": String, "token": String}[/code]. Values that weren't found are empty.
## [code]url[/code] is a websocket URL as expected by the hass_ws adapter.
static func parse(text: String) -> Dictionary:
	var result = {"url": "", "token": ""}
	text = text.strip_edges()

	if text.begins_with("{"):
		var data = JSON.parse_string(text)

		if data is Dictionary:
			for key in ["url", "base_url", "host"]:
				if data.get(key) is String&&data[key] != "":
					result.url = to_websocket_url(data[key])
					break

			for key in ["token", "access_token"]:
				if data.get(key) is String&&is_token(data[key]):
					result.token = data[key].strip_edges()
					break

		return result

	if is_token(text):
		result.token = text
		return result

	result.url = to_websocket_url(text)

	var query_start = text.find("?")
	if result.url != ""&&query_start != -1:
		var query = text.substr(query_start + 1).get_slice("#", 0)

		for pair in query.split("&"):
			var key = pair.get_slice("=", 0)
			var value = pair.substr(key.length() + 1).uri_decode()

			if (key == "access_token"||key == "token")&&is_token(value):
				result.token = value

	return result

## Returns true if [param text] looks like a Home Assistant access token (a JWT).
static func is_token(text: String) -> bool:
	text = text.strip_edges()
	var parts = text.split(".")

	if parts.size() != 3||text.begins_with("eyJ") == false:
		return false

	var regex = RegEx.create_from_string("^[A-Za-z0-9_-]+$")
	for part in parts:
		if regex.search(part) == null:
			return false

	return true

## Turns an address of a Home Assistant instance into the websocket URL of its API, without a path.
## Returns an empty string if [param address] isn't an address.
static func to_websocket_url(address: String) -> String:
	var url = address.strip_edges()
	var scheme = ""

	var scheme_end = url.find("://")
	if scheme_end != -1:
		match url.substr(0, scheme_end).to_lower():
			"http", "ws":
				scheme = "ws"
			"https", "wss":
				scheme = "wss"
			_:
				return ""

		url = url.substr(scheme_end + 3)

	# The websocket path is added when connecting, everything after the host is dropped.
	for separator in ["/", "?", "#"]:
		url = url.get_slice(separator, 0)

	var host_regex = RegEx.create_from_string("^(\\[[0-9A-Fa-f:.]+\\]|[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*)(:\\d{1,5})?$")
	var host_match = host_regex.search(url)

	if host_match == null:
		return ""

	var has_port = host_match.get_string(3) != ""

	if scheme == "":
		# Without a scheme, only accept things that are clearly an address and not just a word.
		if has_port == false&&url.contains(".") == false:
			return ""

		scheme = "ws"

		# Home Assistant's default port, a bare host is very likely a default install.
		if has_port == false:
			url += ":%d" % DEFAULT_PORT

	return "%s://%s" % [scheme, url]
