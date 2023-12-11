extends Node

const VariantSerializer = preload("res://lib/utils/variant_serializer.gd")

func clear():
	_clear_save_tree(get_tree().root.get_node("Main"))

func save():
	if HomeApi.has_connected() == false:
		return

	var filename = HomeApi.api.url.split("//")[1].replace("/api/websocket", "").replace(".", "_").replace(":", "_")

	var save_file = FileAccess.open("user://%s.save" % filename, FileAccess.WRITE)

	if save_file == null:
		return

	var save_tree = _generate_save_tree(get_tree().root.get_node("Main"))

	var json_text = JSON.stringify(save_tree)
	save_file.store_line(json_text)

func load():
	clear()

	if HomeApi.has_connected() == false:
		return

	var filename = HomeApi.api.url.split("//")[1].replace("/api/websocket", "").replace(".", "_").replace(":", "_")

	var save_file = FileAccess.open("user://%s.save" % filename, FileAccess.READ)

	if save_file == null:
		return

	var json_text = save_file.get_line()
	var save_tree = JSON.parse_string(json_text)

	if save_tree is Array:
		for tree in save_tree:
			_build_save_tree(tree)
	else:
		_build_save_tree(save_tree)

func _clear_save_tree(node: Node):
	for child in node.get_children():
		_clear_save_tree(child)

	if node.has_method("_save"):
		node.queue_free()

func _generate_save_tree(node: Node):
	var children = []

	if node.has_method("_save") == false:
		for child in node.get_children():
			var data = _generate_save_tree(child)

			if data is Array:
				for child_data in data:
					children.append(child_data)
			else:
				children.append(data)
		return children
	
	
	var save_tree = {
		"data": VariantSerializer.stringify_value(node.call("_save")),
		"parent": node.get_parent().get_path(),
		"filename": node.get_scene_file_path()
	}

	for child in node.get_children():
		var child_data = _generate_save_tree(child)

		if child_data is Array:
			for data in child_data:
				children.append(data)
		else:
			children.append(child_data)

	save_tree["children"] = children

	return save_tree

func _build_save_tree(tree: Dictionary):
	var new_object = load(tree["filename"]).instantiate()

	if new_object.has_method("_load"):
		new_object.call("_load", VariantSerializer.parse_value(tree["data"]))
	else:
		for key in tree["data"].keys():
			new_object.set(key, VariantSerializer.parse_value(tree["data"][key]))

	get_node(tree["parent"]).add_child(new_object)

	for child in tree["children"]:
		_build_save_tree(child)
