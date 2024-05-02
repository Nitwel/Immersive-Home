extends Node3D

const VoiceAssistant = preload ("res://content/system/assist/assist.tscn")
const environment_passthrough_material = preload ("res://assets/environment_passthrough.tres")

@onready var environment: WorldEnvironment = $WorldEnvironment
@onready var camera: XRCamera3D = $XROrigin3D/XRCamera3D
@onready var controller_left = $XROrigin3D/XRControllerLeft
@onready var controller_right = $XROrigin3D/XRControllerRight
@onready var house = $House
@onready var menu = $Menu
@onready var keyboard = $Keyboard
var voice_assistant = null

func _ready():
	# In case we're running on the headset, use the passthrough sky

	if OS.get_name() == "Android":
		# OS.request_permissions()
		environment.environment = environment_passthrough_material
		get_viewport().transparent_bg = true
	else:
		RenderingServer.set_debug_generate_wireframes(true)

	create_voice_assistant()

	controller_left.button_pressed.connect(func(name):
		_emit_action(name, true, false)
	)

	controller_right.button_pressed.connect(func(name):
		_emit_action(name, true, true)
	)

	controller_left.button_released.connect(func(name):
		_emit_action(name, false, false)
	)

	controller_right.button_released.connect(func(name):
		_emit_action(name, false, true)
	)

	remove_child(keyboard)

	EventSystem.on_action_down.connect(func(action):
		if action.name == "menu_button":
			toggle_menu()
		elif action.name == "by_button":
			House.body.mini_view.small.value=!House.body.mini_view.small.value
		elif action.name == "ax_button":
			if take_screenshot():
				EventSystem.notify("Screenshot taken", EventNotify.Type.INFO)
	)

	EventSystem.on_focus_in.connect(func(event):
		if keyboard.is_inside_tree():
			return

		add_child(keyboard)
		keyboard.global_transform=menu.get_node("AnimationContainer/KeyboardPlace").global_transform
	)

	EventSystem.on_focus_out.connect(func(event):
		if !keyboard.is_inside_tree():
			return

		remove_child(keyboard)
	)

func create_voice_assistant():
	if Store.settings.is_loaded() == false:
		await Store.settings.on_loaded

	var settings_store = Store.settings.state

	R.effect(func(_arg):
		if settings_store.voice_assistant == true&&voice_assistant == null:
			voice_assistant=VoiceAssistant.instantiate()
			add_child(voice_assistant)
		elif settings_store.voice_assistant == false&&voice_assistant != null:
			remove_child(voice_assistant)
			voice_assistant.queue_free()
	)

func toggle_menu():
	menu.show_menu.value = !menu.show_menu.value

func _emit_action(name: String, value, right_controller: bool=true):
	var event = EventAction.new()
	event.name = name
	event.value = value
	event.right_controller = right_controller

	match typeof(value):
		TYPE_BOOL:
			EventSystem.emit("action_down" if value else "action_up", event)
		TYPE_FLOAT, TYPE_VECTOR2:
			EventSystem.emit("action_value", event)

func _process(delta):
	if OS.get_name() != "Android":
		
		var camera_basis = camera.get_global_transform().basis

		camera_basis.x.y = 0
		camera_basis.z.y = 0
		camera_basis.y = Vector3(0, 1, 0)
		camera_basis.x = camera_basis.x.normalized()
		camera_basis.z = camera_basis.z.normalized()

		var movement = camera_basis * vector_key_mapping(KEY_D, KEY_A, KEY_S, KEY_W) * delta

		camera.position += movement
		controller_left.position += movement
		controller_right.position += movement

func _input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_F10):
		var vp = get_viewport()
		vp.debug_draw = (vp.debug_draw + 1) % 5

	if event is InputEventKey and Input.is_key_pressed(KEY_F2):
		take_screenshot()
		
	if event is InputEventKey and Input.is_key_pressed(KEY_M):
		toggle_menu()

func vector_key_mapping(key_positive_x: int, key_negative_x: int, key_positive_y: int, key_negative_y: int):
	var x = 0
	var y = 0
	if Input.is_physical_key_pressed(key_positive_y):
		y = 1
	elif Input.is_physical_key_pressed(key_negative_y):
		y = -1
	
	if Input.is_physical_key_pressed(key_positive_x):
		x = 1
	elif Input.is_physical_key_pressed(key_negative_x):
		x = -1
	
	var vec = Vector3(x, 0, y)
	
	if vec:
		vec = vec.normalized()
	
	return vec

func take_screenshot():
	var vp = get_viewport()
	var texture = vp.get_texture()
	var image = texture.get_image()

	var file_name = "%s.png" % Time.get_datetime_string_from_system().replace(":", "-")

	if image == null:
		return false

	if OS.get_name() == "Android":
		var path = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES, false) + "/immersive-home/" + file_name

		if not FileAccess.file_exists(path):
			var dir = path.get_base_dir()
			DirAccess.open("user://").make_dir_recursive(dir)

		image.save_png(path)
	else:
		image.save_png("user://screenshots/%s.png" % Time.get_datetime_string_from_system().replace(":", "-"))

	return true