extends Node

const VariantSerializer = preload("res://lib/utils/variant_serializer.gd")

var file_url: String = "user://config.cfg"

func save_config(data: Dictionary):
	var file := FileAccess.open(file_url, FileAccess.WRITE)

	if file == null:
		return

	var json_data := JSON.stringify(VariantSerializer.stringify_value(data))
	file.store_string(json_data)

func load_config():
	var file := FileAccess.open(file_url, FileAccess.READ)

	if file == null:
		return {}

	var json_data := file.get_as_text()
	var data = VariantSerializer.parse_value(JSON.parse_string(json_data))

	return data