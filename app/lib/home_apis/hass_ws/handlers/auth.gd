const HASS_API = preload ("../hass.gd")

signal on_authenticated()

var api: HASS_API
var url: String
var token: String

var authenticated := false

func _init(hass: HASS_API, url: String, token: String):
	self.api = hass
	self.url = url
	self.token = token

func handle_message(message):
	match message["type"]:
		"auth_required":
			api.send_packet({"type": "auth", "access_token": self.token})
		"auth_ok":
			authenticated = true
			on_authenticated.emit()
		"auth_invalid":
			EventSystem.notify("Failed to authenticate with Home Assistant. Check your token and try again.", EventNotify.Type.DANGER)
			api.handle_disconnect()

func on_disconnect():
	authenticated = false