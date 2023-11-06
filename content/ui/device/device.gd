extends StaticBody3D

@onready var label: Label3D = $Label
@export var id: String = "0"

signal click(id: String)

func _on_click(event):
	click.emit(id)

func set_device_name(text):
	assert(label != null, "Device has to be added to the scene tree")
	label.text = text