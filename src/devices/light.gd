extends StaticBody3D

@onready var http_request = HTTPRequest.new()
@export var id = "switch.plug_printer_2"
@export var token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIzZjQ0ZGM2N2Y3YzY0MDc1OGZlMWI2ZjJlNmIxZjRkNSIsImlhdCI6MTY5ODAxMDcyOCwiZXhwIjoyMDEzMzcwNzI4fQ.K6ydLUC-4Q7BNIRCU1nWlI2s6sg9UCiOu-Lpedw2zJc"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(http_request)
	http_request.request_completed.connect(self._on_request_completed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_toggle():
	print("Toggling " + id)
	var headers = PackedStringArray(["Authorization: Bearer " + token, "Content-Type: application/json"])

	var error = http_request.request("http://192.168.33.33:8123/api/services/switch/toggle", headers, HTTPClient.METHOD_POST, "{\"entity_id\": \"" + id + "\"}")

	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _on_request_completed():
	pass
