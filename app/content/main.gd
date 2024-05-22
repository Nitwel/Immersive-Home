extends Node3D

const VoiceAssistant = preload ("res://content/system/assist/assist.tscn")
const environment_passthrough_material = preload ("res://assets/environment_passthrough.tres")
const Menu = preload ("res://content/ui/menu/menu.gd")
const OnboardingScene = preload ("res://content/ui/onboarding/onboarding.tscn")

@onready var environment: WorldEnvironment = $WorldEnvironment
@onready var camera: XRCamera3D = %XRCamera3D
@onready var controller_left = %XRControllerLeft
@onready var controller_right = %XRControllerRight
@onready var house = $House
@onready var menu: Menu = $Menu
@onready var xr: XRToolsStartXR = $StartXR
var voice_assistant = null

func _ready():
	if OS.get_name() == "Android":
		# OS.request_permissions()
		environment.environment = environment_passthrough_material
		get_viewport().transparent_bg = true
	else:
		RenderingServer.set_debug_generate_wireframes(true)

	create_voice_assistant()

	xr.xr_started.connect(func():
		if HomeApi.has_connected() == false:
			HomeApi.start()
	)

	HomeApi.on_connect.connect(func():
		start_setup_flow.call_deferred()
	)

func start_setup_flow():
	var onboarding = OnboardingScene.instantiate()
	add_child(onboarding)

	await onboarding.tree_exited

	if Store.house.state.rooms.size() == 0:
		house.create_room("Room 1")

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

func _process(delta):
	_move_camera_pc(delta)

func _input(event):

	# Debugging Features
	if event is InputEventKey and Input.is_key_pressed(KEY_F10):
		var vp = get_viewport()
		vp.debug_draw = (vp.debug_draw + 1) % 5
		
	if event is InputEventKey and Input.is_key_pressed(KEY_M):
		menu.toggle_open()

func _move_camera_pc(delta):
	if OS.get_name() == "Android": return
		
	var camera_basis = camera.get_global_transform().basis

	camera_basis.x.y = 0
	camera_basis.z.y = 0
	camera_basis.y = Vector3(0, 1, 0)
	camera_basis.x = camera_basis.x.normalized()
	camera_basis.z = camera_basis.z.normalized()

	var movement = camera_basis * _vector_key_mapping(KEY_D, KEY_A, KEY_S, KEY_W) * delta

	camera.position += movement
	controller_left.position += movement
	controller_right.position += movement

func _vector_key_mapping(key_positive_x: int, key_negative_x: int, key_positive_y: int, key_negative_y: int):
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