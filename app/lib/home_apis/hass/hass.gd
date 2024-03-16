extends Node

var url: String = "http://192.168.33.33:8123"
var token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIzZjQ0ZGM2N2Y3YzY0MDc1OGZlMWI2ZjJlNmIxZjRkNSIsImlhdCI6MTY5ODAxMDcyOCwiZXhwIjoyMDEzMzcwNzI4fQ.K6ydLUC-4Q7BNIRCU1nWlI2s6sg9UCiOu-Lpedw2zJc"
var headers: PackedStringArray = PackedStringArray([])

var devices_template = FileAccess.get_file_as_string("res://lib/home_apis/hass/templates/devices.j2")

func _init(url := self.url, token := self.token):
	self.url = url
	self.token = token

	headers = PackedStringArray(["Authorization: Bearer %s" % token, "Content-Type: application/json"])
	devices_template = devices_template.replace("\n", " ").replace("\t", "").replace("\r", " ").replace("\"", "\\\"")

func get_devices():
	Request.request("%s/api/template" % [url], headers, HTTPClient.METHOD_POST, "{\"template\": \"%s\"}" % [devices_template])
	var response = await Request.request_completed
	var data_string = response[3].get_string_from_utf8().replace("'", "\"")
	var json = JSON.parse_string(data_string).data

	return json

func get_state(entity: String):
	var type = entity.split('.')[0]

	Request.request("%s/api/states/%s" % [url, entity], headers, HTTPClient.METHOD_GET)
	var response = await Request.request_completed

	var data_string = response[3].get_string_from_utf8().replace("'", "\"")
	var json = JSON.parse_string(data_string)

	return json

func set_state(entity: String, state: String, attributes: Dictionary = {}):
	var type = entity.split('.')[0]
	var response

	if type == 'switch':
		if state == 'on':
			Request.request("%s/api/services/switch/turn_on" % [url], headers, HTTPClient.METHOD_POST, "{\"entity_id\": \"%s\"}" % [entity])
			response = await Request.request_completed
		elif state == 'off':
			Request.request("%s/api/services/switch/turn_off" % [url], headers, HTTPClient.METHOD_POST, "{\"entity_id\": \"%s\"}" % [entity])
			response = await Request.request_completed
	elif type == 'light':
		if state == 'on':
			Request.request("%s/api/services/light/turn_on" % [url], headers, HTTPClient.METHOD_POST, "{\"entity_id\": \"%s\"}" % [entity])
			response = await Request.request_completed
		elif state == 'off':
			Request.request("%s/api/services/light/turn_off" % [url], headers, HTTPClient.METHOD_POST, "{\"entity_id\": \"%s\"}" % [entity])
			response = await Request.request_completed
	
	var data_string = response[3].get_string_from_utf8().replace("'", "\"")
	var json = JSON.parse_string(data_string)

	return json
	
