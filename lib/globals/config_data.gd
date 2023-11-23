extends Node

var file_url: String = "user://config.json"

func save_config(data: Dictionary):
	var file := FileAccess.open(file_url, FileAccess.WRITE)

	if file == null:
		return

	var json_data := JSON.stringify(data)
	file.store_string(json_data)

func load_config():
	var file := FileAccess.open(file_url, FileAccess.READ)

	if file == null:
		return {}

	var json_data := file.get_as_text()
	var data = JSON.parse_string(json_data)

	return data