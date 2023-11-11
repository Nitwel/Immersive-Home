extends StaticBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_press_down(_event):
	animation_player.play("down")

func _on_press_up(_event):
	animation_player.play("up")
