extends Node3D

var sky = preload("res://assets/materials/sky.material")
var sky_passthrough = preload("res://assets/materials/sky_passthrough.material")

@export var passthrough: bool = true
@onready var environment: WorldEnvironment = $WorldEnvironment

func _ready():
	if passthrough:
		environment.environment.sky.set_material(sky_passthrough)