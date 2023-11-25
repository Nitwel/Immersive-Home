extends StaticBody3D

@onready var close = $Content/Button

func _ready():
	close.on_button_down.connect(func():
		queue_free()
	)
