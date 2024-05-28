extends StaticBody3D

const Light = preload ("./light.gd")

@onready var close_button: Button3D = $Close
@onready var id_input: Input3D = $IDInput
@onready var color_wheel_button: Button3D = $ColorWheelButton
@onready var brightness_button: Button3D = $BrightnessButton
@onready var modes_button: Button3D = $ModesButton

var light: Light

func _ready():
	light = get_parent()

	close_button.on_button_up.connect(func():
		light.show_settings.value=false
	)

	id_input.text = light.entity_id

	R.effect(func(_arg):
		color_wheel_button.label="check" if light.show_color_wheel.value else "close"
	)

	R.effect(func(_arg):
		brightness_button.label="check" if light.show_brightness.value else "close"
	)

	R.effect(func(_arg):
		modes_button.label="check" if light.show_modes.value else "close"
	)

	R.bind(color_wheel_button, "active", light.show_color_wheel, color_wheel_button.on_toggled)
	R.bind(brightness_button, "active", light.show_brightness, brightness_button.on_toggled)
	R.bind(modes_button, "active", light.show_modes, modes_button.on_toggled)
