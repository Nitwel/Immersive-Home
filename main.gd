extends Node3D

var sky = preload("res://assets/materials/sky.material")
var sky_passthrough = preload("res://assets/materials/sky_passthrough.material")

@onready var environment: WorldEnvironment = $WorldEnvironment

func _ready():
	# In case we're running on the headset, use the passthrough sky
	if OS.get_name() == "Android":
		environment.environment.sky.set_material(sky_passthrough)
