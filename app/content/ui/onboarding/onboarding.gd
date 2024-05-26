extends Node3D

@onready var getting_started_button = $GettingStartedButton
@onready var close_button = $CloseButton

func _ready():
	if Store.settings.is_loaded() == false:
		await Store.settings.on_loaded

	if (Store.settings.state.url != ""&&Store.settings.state.url != null)||Store.settings.state.onboarding_complete:
		close()
		return

	getting_started_button.on_button_down.connect(func():
		OS.shell_open("https://docs.immersive-home.org/")
	)

	close_button.on_button_down.connect(func():
		close()
	)

func close():
	Store.settings.state.onboarding_complete = true
	Store.settings.save_local()
	queue_free()
