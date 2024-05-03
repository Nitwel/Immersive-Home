extends RefCounted
## Abstract class for saving and loading data to and from a file.

const VariantSerializer = preload ("res://lib/utils/variant_serializer.gd")

## Signal emitted when the data is loaded.
signal on_loaded

## Signal emitted when the data is saved.
signal on_saved

var state: RdotStore
var _loaded = false
var _save_path = null

## Returns true if the data has been loaded.
func is_loaded():
	return _loaded

## Resets the data to its default state.
func clear():
	pass

func sanitizeState(dict=state):
	var data = {}

	for prop_info in state.get_property_list():
		var key = prop_info.name

		if key.begins_with("_")||(prop_info.has("hint_string")&&prop_info.hint_string != ""):
			continue

		if dict[key] is Dictionary:
			data[key] = sanitizeState(dict[key])
		else:
			data[key] = VariantSerializer.stringify_value(dict[key])

	return data

func use_dict(dict: Dictionary, target=state):
	for prop_info in state.get_property_list():
		var key = prop_info.name

		if key.begins_with("_")||(prop_info.has("hint_string")&&prop_info.hint_string != ""):
			continue

		if dict.has(key) == false:
			continue

		if target[key] is Dictionary:
			use_dict(dict[key], target[key])
		else:
			target[key] = dict[key]

func save_local(path=_save_path):
	if path == null:
		return false

	var data = sanitizeState()

	var save_file = FileAccess.open(path, FileAccess.WRITE)

	if save_file == null:
		return false

	var json_text = JSON.stringify(data)
	save_file.store_line(json_text)

	# var path2 = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS, false) + "/immersive-home/" + path.split("/")[- 1]
	# path2 = path2.replace("/Android/data/org.godotengine.immersivehome/files", "")

	# print(path2)

	# if not FileAccess.file_exists(path2):
	# 	var dir = path2.get_base_dir()
	# 	DirAccess.open("user://").make_dir_recursive(dir)

	# var save_file2 = FileAccess.open(path2, FileAccess.WRITE)

	# if save_file2 == null:
	# 	return false

	# save_file2.store_line(json_text)

	on_saved.emit()

	return true

func load_local(path=_save_path):
	if path == null:
		return false

	var save_file = FileAccess.open(path, FileAccess.READ)

	# In case that there is no store file yet
	if save_file == null:
		_loaded = true
		on_loaded.emit()
		return true

	var json_text = save_file.get_as_text()
	var save_data = VariantSerializer.parse_value(JSON.parse_string(json_text))

	if save_data == null:
		return false

	use_dict(save_data)

	_loaded = true
	on_loaded.emit()

	return true
