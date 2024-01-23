extends Node3D

const window_scene = preload("./window.tscn")

@onready var background = $Background

func _ready():
	background.visible = false

	HomeApi.on_connect.connect(func():
		# var rooms = House.body.get_rooms(0)

		# for room in rooms:
		# 	var mesh = room.wall_mesh
		pass
	)
