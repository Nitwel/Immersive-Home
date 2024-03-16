extends StoreClass
## Stores general settings for the app

const StoreClass = preload ("./store.gd")

## The adapter to use for connecting with a backend
var type: String = "HASS_WS"
var url: String = ""
var token: String = ""

## If the voice assistant should be enabled
var voice_assistant: bool = false

func _init():
	_save_path = "user://settings.json"

func clear():
	type = "HASS_WS"
	url = ""
	token = ""
	voice_assistant = false