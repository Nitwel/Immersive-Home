@tool
extends Container3D
class_name LabelContainer3D

const FontTools = preload ("res://lib/utils/font_tools.gd")

@onready var label: Label3D = $Label3D

@export var text: String = "Example":
	set(value):
		text = value
		
		if !is_inside_tree(): return

		_update_text()

func _ready():
	print("label %s enter tree" % text)
	_update_text()

func _update_text():
	label.text = text
	var text_size = FontTools.get_font_size(label)
	size = Vector3(text_size.x, text_size.y, 0.1)
	print("label %s size %s" % [text, size])