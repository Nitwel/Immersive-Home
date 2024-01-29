extends Node3D

const ball_scene = preload("./ball.tscn")
const credits_scene = preload("./credits.tscn")

@onready var ball_button = $Content/Button
@onready var connection_status = $Content/ConnectionStatus

@onready var input_url = $Content/InputURL
@onready var input_token = $Content/InputToken
@onready var button_connect = $Content/Connect
@onready var credits = $Content/Credits/Clickable
@onready var save = $Content/Save
@onready var clear_save = $Content/ClearSave
@onready var background = $Background

func _ready():
	background.visible = false

	ball_button.on_button_down.connect(func():
		var ball = ball_scene.instantiate()
		var controller = XRHelpers.get_right_controller(self)

		ball.transform = controller.transform
		ball.linear_velocity = -controller.transform.basis.z * 5 + Vector3(0, 5, 0)
		get_tree().root.add_child(ball)
	)

	credits.on_click.connect(func(_event):
		var credits_instance = credits_scene.instantiate()
		get_tree().root.add_child(credits_instance)
		var label = $Content/Credits/Label
		credits_instance.global_position =  + label.to_global(label.position + Vector3(0.1, 0, -0.15))
	)

	if Store.settings.is_loaded():
		input_url.text = Store.settings.url
		input_token.text = Store.settings.token
	else:
		Store.settings.on_loaded.connect(func():
			input_url.text = Store.settings.url
			input_token.text = Store.settings.token
		)

	button_connect.on_button_down.connect(func():
		var url = input_url.text
		var token = input_token.text

		HomeApi.start_adapter("hass_ws", url, token)

		Store.settings.url = url
		Store.settings.token = token

		Store.settings.save_local()
	)

	save.on_button_down.connect(func():
		House.body.save_all_entities()
		Store.house.save_local()
	)

	clear_save.on_button_down.connect(func():
		Store.house.clear()
		House.body.update_house()
	)

	HomeApi.on_connect.connect(func():
		connection_status.text = "Connected"
	)

	HomeApi.on_disconnect.connect(func():
		connection_status.text = "Disconnected"
	)
	
