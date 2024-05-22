extends Node3D

@onready var voice_assist = $VoiceAssist
@onready var cursor_options = $CursorOptions

func _ready():
	var settings_store = Store.settings.state

	if Store.settings.is_loaded() == false:
		await Store.settings.on_loaded

	var button_label = R.computed(func(_arg):
		return "mic_off" if settings_store.voice_assistant == false else "mic"
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

	cursor_options.selected.value = settings_store.cursor_style

	cursor_options.on_select.connect(func(option):
		settings_store.cursor_style=option
		settings_store.cursor_style=option
		Store.settings.save_local()
	)

	R.bind(voice_assist, "label", button_label)
	R.bind(voice_assist, "active", settings_store, "voice_assistant")
