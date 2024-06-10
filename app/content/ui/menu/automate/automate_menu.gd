extends Node3D

@onready var background = $Background

func _ready():
	background.visible = false

	visibility_changed.connect(func():
		if visible:
			pass
	)
