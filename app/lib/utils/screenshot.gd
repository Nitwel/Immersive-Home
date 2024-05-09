extends Node

const photo_sound_stream = preload ("res://assets/sound/camera-shutter.mp3")

var timer = Timer.new()
var photo_sound = AudioStreamPlayer.new()

func _ready():
	timer.wait_time = 2
	timer.one_shot = true

	photo_sound.stream = photo_sound_stream
	photo_sound.volume_db = -10

	EventSystem.on_action_down.connect(func(action):
		if action.name == "ax_button":
			timer.start()
	)

	timer.timeout.connect(func():
		EventSystem.notify("Screenshot taken", EventNotify.Type.INFO)
		take_screenshot()
	)

	add_child(timer)
	add_child(photo_sound)

func _input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_F2):
		timer.start()

func take_screenshot():
	var file_name = "%s.png" % Time.get_datetime_string_from_system().replace(":", "-")

	var path = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES) + "/immersive-home/" + file_name

	print("Saving screenshot to: %s" % path)

	if not FileAccess.file_exists(path):
		var dir = path.get_base_dir()
		DirAccess.open("user://").make_dir_recursive(dir)

	var image

	if OS.get_name() == "Android":
		var viewport_rid = get_viewport().get_viewport_rid()
		var texture_rid = RenderingServer.viewport_get_texture(viewport_rid)
		image = RenderingServer.texture_2d_layer_get(texture_rid, 0)
		print(image)

		if image == null:
			return false

	else:
		var vp = get_viewport()
		var texture = vp.get_texture()
		image = texture.get_image()

		if image == null:
			return false

	image.save_png(path)
	photo_sound.play()

	return true