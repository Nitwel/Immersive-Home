extends Node3D

const ball_scene = preload("res://content/ui/menu/settings/ball.tscn")

@onready var clickable = $Content/Button/Clickable
@onready var connection_status = $Content/ConnectionStatus

@onready var input_url = $Content/InputURL
@onready var input_token = $Content/InputToken
@onready var button_connect = $Content/Connect

func _ready():
	clickable.on_click.connect(func(event):
		var ball = ball_scene.instantiate()
		ball.transform = event.controller.transform
		ball.linear_velocity = -event.controller.transform.basis.z * 5 + Vector3(0, 5, 0)
		get_tree().root.add_child(ball)
	)

	var config = ConfigData.load_config()

	if config.has("url"):
		input_url.text = config["url"]
	if config.has("token"):
		input_token.text = config["token"]

	button_connect.on_button_down.connect(func():
		HomeAdapters.adapter.adapter.url = input_url.text + "/api/websocket"
		HomeAdapters.adapter.adapter.token = input_token.text
		HomeAdapters.adapter.adapter.retries = 5
		HomeAdapters.adapter.adapter.connect_ws()

		ConfigData.save_config({
			"url": input_url.text,
			"token": input_token.text
		})
	)

	HomeAdapters.adapter.adapter.on_connect.connect(func():
		connection_status.text = "Connected"
	)

	HomeAdapters.adapter.adapter.on_disconnect.connect(func():
		connection_status.text = "Disconnected"
	)
	
