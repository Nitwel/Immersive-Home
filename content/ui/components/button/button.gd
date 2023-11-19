extends StaticBody3D
class_name Button3D

@export var toggleable: bool = false
@export var disabled: bool = false
@export var initial_active: bool = false
var active: bool = false :
	set(value):
		print("set active", value)
		animation_player.stop()
		if value == active:
			return

		active = value

		if active:
			animation_player.play("down")
		else:
			animation_player.play_backwards("down")
	get:
		return active	

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var click_sound: AudioStreamPlayer = $ClickSound

func _ready():
	if initial_active:
		active = true

func _on_click(_event):
	if disabled:
		return false

	if !toggleable:
		return

	active = !active
	AudioPlayer.play_effect("click")

	return {
		"active": active
	}

func _on_press_down(_event):
	if disabled:
		return false

	if toggleable:
		return
	
	AudioPlayer.play_effect("click")
	animation_player.play("down")

func _on_press_up(_event):
	if disabled:
		return false

	if toggleable:
		return

	animation_player.play_backwards("down")
