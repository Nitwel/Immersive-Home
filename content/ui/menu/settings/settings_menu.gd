extends Node3D

const ball_scene = preload("res://content/ui/menu/settings/ball.tscn")

@onready var clickable = $Content/Button/Clickable
@onready var connection_status = $Content/ConnectionStatus

func _ready():
	clickable.on_click.connect(func(event):
		var ball = ball_scene.instantiate()
		ball.transform = event.controller.transform
		ball.linear_velocity = -event.controller.transform.basis.z * 5 + Vector3(0, 5, 0)
		get_tree().root.add_child(ball)
	)

	HomeAdapters.adapter.adapter.on_connect.connect(func():
		connection_status.text = "Connected"
	)

	HomeAdapters.adapter.adapter.on_disconnect.connect(func():
		connection_status.text = "Disconnected"
	)
	
