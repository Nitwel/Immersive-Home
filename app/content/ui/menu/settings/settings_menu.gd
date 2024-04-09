extends Node3D

const credits_scene = preload ("./credits.tscn")

@onready var connection_status = $Content/ConnectionStatus

@onready var input_url = $Content/InputURL
@onready var input_token = $Content/InputToken
@onready var button_connect = $Content/Connect
@onready var credits = $Content/Credits/Clickable
@onready var save = $Content/Save
@onready var clear_save = $Content/ClearSave
@onready var background = $Background
@onready var voice_assist = $Content/VoiceAssist

func _ready():
	var settings_store = Store.settings.state
	
	background.visible = false

	credits.on_click.connect(func(_event):
		var credits_instance=credits_scene.instantiate()
		get_tree().root.add_child(credits_instance)
		var label=$Content/Credits/Label
		credits_instance.global_position=+ label.to_global(label.position + Vector3(0.1, 0, -0.15))
	)

	if Store.settings.is_loaded():
		input_url.text = settings_store.url
		input_token.text = settings_store.token
	else:
		Store.settings.on_loaded.connect(func():
			input_url.text=settings_store.url
			input_token.text=settings_store.token
		)

	button_connect.on_button_down.connect(func():
		var url=input_url.text
		var token=input_token.text

		HomeApi.start_adapter("hass_ws", url, token)

		settings_store.url=url
		settings_store.token=token

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

	voice_assist.on_button_down.connect(func():
		if Store.settings.is_loaded() == false:
			await Store.settings.on_loaded

		OS.request_permissions()

		voice_assist.label="mic"

		settings_store.voice_assistant=true
		Store.settings.save_local()
	)

	voice_assist.on_button_up.connect(func():
		if Store.settings.is_loaded() == false:
			await Store.settings.on_loaded

		voice_assist.label="mic_off"

		settings_store.voice_assistant=false
		Store.settings.save_local()

	)

	HomeApi.on_connect.connect(func():
		connection_status.text="Connected"
	)

	HomeApi.on_disconnect.connect(func():
		connection_status.text="Disconnected"
	)

	if Store.settings.is_loaded() == false:
		await Store.settings.on_loaded

	var button_label = R.computed(func(_arg):
		return "mic_off" if settings_store.voice_assistant == false else "mic"
	)

	R.bind(voice_assist, "label", button_label)
	R.bind(voice_assist, "active", settings_store, "voice_assistant")
