extends Node3D

@onready var label: Label3D = $Button/Label
@export var id: String = "0"

func set_device_name(text):
	assert(label != null, "Device has to be added to the scene tree")
	label.text = text
