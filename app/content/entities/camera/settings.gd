extends Node3D

const Camera = preload ("./camera.gd")

@onready var close_button: Button3D = $Close
@onready var id_input: Input3D = $IDInput
@onready var video_button: Button3D = $VideoButton
@onready var fps_slider: Slider3D = $FPSSlider

var camera: Camera

func _ready():
	camera = get_parent()

	close_button.on_button_up.connect(func():
		camera.show_settings.value=false
	)

	id_input.text = camera.entity_id

	R.effect(func(_arg):
		video_button.label="videocam" if camera.cam_active.value else "videocam_off"
	)

	R.bind(video_button, "active", camera.cam_active, video_button.on_toggled)
	R.bind(fps_slider, "value", camera.cam_fps, fps_slider.on_value_changed)
