extends Node

var url: String = "http://192.168.33.33:8123"
var token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIzZjQ0ZGM2N2Y3YzY0MDc1OGZlMWI2ZjJlNmIxZjRkNSIsImlhdCI6MTY5ODAxMDcyOCwiZXhwIjoyMDEzMzcwNzI4fQ.K6ydLUC-4Q7BNIRCU1nWlI2s6sg9UCiOu-Lpedw2zJc"
var headers: PackedStringArray = PackedStringArray([])

var devices_template = FileAccess.get_file_as_string("res://src/home_adapters/hass/templates/devices.j2")

func _init(url := self.url, token := self.token):
	self.url = url
	self.token = token

	headers = PackedStringArray(["Authorization: Bearer %s" % token, "Content-Type: application/json"])
	devices_template = devices_template.replace("\n", " ").replace("\t", "").replace("\r", " ").replace("\"", "\\\"")

func load_devices():
	Request.request("%s/api/template" % [url], headers, HTTPClient.METHOD_POST, "{\"template\": \"%s\"}" % [devices_template])
	var response = await Request.request_completed
	var data_string = response[3].get_string_from_utf8().replace("'", "\"")
	var json = JSON.parse_string(data_string).data

	print(json)
	return json
