extends Node3D

@onready var mini_view = $Content/MiniView
@onready var background = $Background

func _ready():
	background.visible = false

	mini_view.on_button_down.connect(func():
		House.body.mini_view.small.value=!House.body.mini_view.small.value
	)
