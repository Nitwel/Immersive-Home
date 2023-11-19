extends AudioStreamPlayer

var click_sound = preload("res://assets/sound/click.wav")
var spawn_sound = preload("res://assets/sound/spawn.wav")

func _ready():
	volume_db = -18

func play_effect(sound):
	if sound == "click":
		stream = click_sound
	elif sound == "spawn":
		stream = spawn_sound
	
	play()
