extends Node3D

@onready var status_label = $LabelStatus
@onready var input_url = $InputURL
@onready var input_token = $InputToken
@onready var button_connect = $Connect

func _ready():
	var settings_store = Store.settings.state

	if Store.settings.is_loaded() == false:
		await Store.settings.on_loaded

	input_url.text = settings_store.url
	input_token.text = settings_store.token

	button_connect.on_button_down.connect(func():
		var url=input_url.text
		var token=input_token.text

		HomeApi.start_adapter("hass_ws", url, token)

		settings_store.url=url
		settings_store.token=token

		Store.settings.save_local()
	)

	HomeApi.on_connect.connect(func():
		status_label.text="Status: Connected"
	)

	HomeApi.on_disconnect.connect(func():
		status_label.text="Status: Disconnected"
	)
