extends Node3D

@onready var getting_started_button = $GettingStartedButton
@onready var close_button = $CloseButton
@onready var camera = $"/root/Main/XROrigin3D/XRCamera3D"
var next_new_position = null

func _ready():
	next_new_position = global_position
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

	EventSystem.on_slow_tick.connect(_slow_tick)

func close():
	Store.settings.state.onboarding_complete = true
	Store.settings.save_local()
	queue_free()

func _slow_tick(delta):
	var new_position = camera.global_position + camera.global_transform.basis.z * - 0.5
		
	if next_new_position.distance_to(new_position) > 0.2:
		next_new_position = new_position
		var new_direction = Basis.looking_at((camera.global_position - new_position) * - 1)

		var tween = create_tween()
		tween.set_parallel(true)
		tween.set_trans(Tween.TransitionType.TRANS_QUAD)
		
		tween.tween_property(self, "global_position", new_position, 0.6)
		tween.tween_property(self, "global_transform:basis", new_direction, 0.6)
