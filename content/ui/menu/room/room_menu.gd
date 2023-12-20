extends Node3D

const Room = preload("res://content/system/house/room/room.tscn")
const RoomType = preload("res://content/system/house/room/room.gd")

const window_scene = preload("./window.tscn")

@onready var background = $Background

func _ready():
	background.visible = false

	HomeApi.on_connect.connect(func():
		var rooms = House.body.get_rooms(0)

		for room in rooms:
			var mesh = room.wall_mesh

		


	)
