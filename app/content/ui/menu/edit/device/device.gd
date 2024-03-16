extends Node3D

@onready var button = $Button
@export var id: String = "0"

func set_device_name(text):
	assert(button != null, "Device has to be added to the scene tree")
	button.label = text
