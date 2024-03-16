extends AudioStreamPlayer

const click_sound = preload ("res://assets/sound/click.wav")
const spawn_sound = preload ("res://assets/sound/spawn.wav")
const open_menu = preload ("res://assets/sound/open_menu.wav")
const close_menu = preload ("res://assets/sound/close_menu.wav")

func _ready():
	volume_db = -18

## Plays a given sound effect
func play_effect(sound):
	if sound == "click":
		stream = click_sound
		volume_db = -18
	elif sound == "spawn":
		stream = spawn_sound
		volume_db = -10
	elif sound == "open_menu":
		stream = open_menu
		volume_db = -6
	elif sound == "close_menu":
		stream = close_menu
		volume_db = -6
	
	play()
