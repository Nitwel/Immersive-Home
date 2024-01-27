extends StoreClass

const StoreClass = preload("./store.gd")


var type: String = "HASS_WS"
var url: String = ""
var token: String = ""

func _init():
	_save_path = "user://settings.json"

func clear():
	type = "HASS_WS"
	url = ""
	token = ""