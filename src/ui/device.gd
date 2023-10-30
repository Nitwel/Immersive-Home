extends StaticBody3D

@onready var label: Label3D = $Label

signal click(name: String)

func _on_toggle():
	click.emit(label.text)

func set_device_name(text):
	assert(label != null, "Device has to be added to the scene tree")
	label.text = text