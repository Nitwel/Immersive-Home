extends StoreClass

const StoreClass = preload ("./store.gd")

var type: String = "HASS_WS"
var url: String = ""
var token: String = ""
var voice_assistant: bool = false

func _init():
	_save_path = "user://settings.json"

func clear():
	type = "HASS_WS"
	url = ""
	token = ""
	voice_assistant = false