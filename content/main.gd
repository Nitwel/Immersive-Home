extends Node3D

var sky = preload("res://assets/materials/sky.material")
var sky_passthrough = preload("res://assets/materials/sky_passthrough.material")

@onready var environment: WorldEnvironment = $WorldEnvironment
@onready var camera: XRCamera3D = $XROrigin3D/XRCamera3D
@onready var controller_left = $XROrigin3D/XRControllerLeft
@onready var controller_right = $XROrigin3D/XRControllerRight
@onready var house = $House

func _ready():
	# In case we're running on the headset, use the passthrough sky
	if OS.get_name() == "Android":
		# OS.request_permissions()
		environment.environment.sky.set_material(sky_passthrough)
		house.visible = false
	else:
		house.visible = true

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
	
	var vec = Vector3(x, 0 , y)
	
	if vec:
		vec = vec.normalized()
	
	return vec