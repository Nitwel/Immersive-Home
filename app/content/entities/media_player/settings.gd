extends StaticBody3D

const MediaPlayer = preload ("./media_player.gd")

@onready var close_button: Button3D = $Close
@onready var id_input: Input3D = $IDInput
@onready var volume_button: Button3D = $VolumeButton
@onready var image_button: Button3D = $ImageButton

var media_player: MediaPlayer

func _ready():
	media_player = get_parent()

	close_button.on_button_up.connect(func():
		media_player.show_settings.value=false
	)

	id_input.text = media_player.entity_id

	R.effect(func(_arg):
		volume_button.label="check" if media_player.show_volume.value else "close"
	)

	R.effect(func(_arg):
		image_button.label="check" if media_player.show_image.value else "close"
	)

	R.bind(volume_button, "active", media_player.show_volume, volume_button.on_toggled)
	R.bind(image_button, "active", media_player.show_image, image_button.on_toggled)