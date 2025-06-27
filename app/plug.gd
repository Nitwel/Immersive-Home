extends "res://addons/gd-plug/plug.gd"

func _plugging():
	# godot-xr-tools
	plug("GodotVR/godot-xr-tools", {"commit": "4d53140015ba5feb6f6ec07873f050311ffe1fdc"})
	# TODO
	plug("bnjmntmm/godot-exoplayer")
	# mqtt
	plug("goatchurchprime/godot-mqtt")
	# promise
	plug("TheWalruzz/godot-promise")
	# rdot
	plug("Nitwel/Rdot")
	# xr-autohandtracker
	plug("Godot-Dojo/Godot-XR-AH", {"include":["addons/xr-autohandtracker"]})
	# xr-simulator
	plug("Cafezinhu/godot-vr-simulator", {"commit": "5bedbbacf6fe40af10e0bfea99487c84387b19f3"})
	
	await download_modules([
		{
			"url": "https://github.com/path9263/godot-cdt/releases/download/1.0.0/godot-cdt-1.0.0-win64.zip",
			"target_dir": "godot-cdt",
			"strip_prefix": "bin/"  # Remove the 'bin/' prefix from paths
		},
		{
			"url": "https://github.com/GodotVR/godot_openxr_vendors/releases/download/4.0.0-stable/godotopenxrvendorsaddon.zip",
			"target_dir": "godotopenxrvendors",
			"strip_prefix": "asset/addons/godotopenxrvendors/"  # Remove the nested path
		}
	])

var path = "res://"

func download_modules(module_configs: Array):
	var http_request = HTTPRequest.new()
	root.add_child(http_request)
	await create_timer(0.2).timeout
	http_request.request_completed.connect(on_http_request_completed)
	for config in module_configs:
		current_module_config = config
		print("Downloading from: ", config.url)
		await create_timer(1.0).timeout
		var error = http_request.request(config.url)
		if error != OK:
			push_error("An error occurred in the HTTP request. Error code: %s" % error)
			continue
		
		await http_request.request_completed
	
	http_request.queue_free()

var current_module_config = {}



func on_http_request_completed(result, response_code, headers, body):
	if response_code == 200:
		print("Download completed successfully.")
		var file = FileAccess.open("res://tmp.zip", FileAccess.WRITE)
		file.store_buffer(body)
		file.close()
		extract_module_from_zip(current_module_config)


# NOTE: this could be done much better.
func extract_module_from_zip(config: Dictionary):
	await create_timer(0.5).timeout
	var reader = ZIPReader.new()
	reader.open("res://tmp")
	var root_dir = DirAccess.open("res://addons/")
	var files = reader.get_files()
	
	var target_dir = config.get("target_dir", "")
	var strip_prefix = config.get("strip_prefix", "")

	if target_dir != "":
		root_dir.make_dir_recursive(target_dir)
	
	for file_path in files:
		var adjusted_path = file_path
		
		if strip_prefix != "" and file_path.begins_with(strip_prefix):
			adjusted_path = file_path.substr(strip_prefix.length())
		
		if adjusted_path == "" or adjusted_path == "/":
			continue
		
		if target_dir != "":
			adjusted_path = target_dir + "/" + adjusted_path
		
		var final_path = "res://addons/" + adjusted_path
		
		if file_path.ends_with("/"):
			DirAccess.open("res://").make_dir_recursive(final_path)
			continue
		
		var parent_dir = final_path.get_base_dir()
		DirAccess.open("res://").make_dir_recursive(parent_dir)

		var file = FileAccess.open(final_path, FileAccess.WRITE)
		if file:
			var buffer = reader.read_file(file_path)
			file.store_buffer(buffer)
			file.close()
		else:
			push_error("Could not create file: " + final_path)
	
	reader.close()
	DirAccess.remove_absolute("res://tmp")
	print("Module extracted successfully to addons/" + target_dir)