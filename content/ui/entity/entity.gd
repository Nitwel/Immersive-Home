extends StaticBody3D

@onready var label: Label3D = $Label
@export var text = "Default"

func set_entity_name(text):
	assert(label != null, "Entity has to be added to the scene tree")
	label.text = text.replace(".", "\n")
	self.text = text
