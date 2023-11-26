extends Node3D

const ball_scene = preload("./ball.tscn")
const credits_scene = preload("./credits.tscn")

@onready var clickable = $Content/Button/Clickable
@onready var connection_status = $Content/ConnectionStatus

@onready var input_url = $Content/InputURL
@onready var input_token = $Content/InputToken
@onready var button_connect = $Content/Connect
@onready var credits = $Content/Credits/Clickable
@onready var background = $Background

func _ready():
	background.visible = false

	clickable.on_click.connect(func(event):
		var ball = ball_scene.instantiate()
		ball.transform = event.controller.transform
		ball.linear_velocity = -event.controller.transform.basis.z * 5 + Vector3(0, 5, 0)
		get_tree().root.add_child(ball)
	)

	credits.on_click.connect(func(_event):
		print("_active_controller")
		var credits_instance = credits_scene.instantiate()
		get_tree().root.add_child(credits_instance)
		var label = $Content/Credits/Label
		credits_instance.global_position =  + label.to_global(label.position + Vector3(0.1, 0, -0.15))
	)

	var config = ConfigData.load_config()

	if config.has("url"):
		input_url.text = config["url"]
	if config.has("token"):
		input_token.text = config["token"]

	button_connect.on_button_down.connect(func():
		var url = input_url.text + "/api/websocket"
		var token = input_token.text

		HomeApi.start_adapter("hass_ws", url, token)

		ConfigData.save_config({
			"api_type": "hass_ws",
			"url": input_url.text,
			"token": input_token.text
		})
	)

	HomeApi.on_connect.connect(func():
		connection_status.text = "Connected"
	)

	HomeApi.on_disconnect.connect(func():
		connection_status.text = "Disconnected"
	)
	
