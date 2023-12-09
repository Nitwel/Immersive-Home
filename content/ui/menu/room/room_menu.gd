extends Node3D

const Room = preload("res://content/system/room/room.tscn")

const window_scene = preload("./window.tscn")

@onready var background = $Background
@onready var toggle_edit_button = $Interface/ToggleEdit
@onready var spawn_windows = $SpawnWindows
@onready var rooms = get_tree().root.get_node("Main/Rooms")
var room: Node3D

func _ready():
	background.visible = false

	HomeApi.on_connect.connect(func():
		if rooms.get_child_count() == 0:
			room = Room.instantiate()
			rooms.add_child(room)
		else:
			room = rooms.get_child(0)
	)

	spawn_windows.on_button_down.connect(func():
		get_tree().root.get_node("Main").add_child.call_deferred(window_scene.instantiate())
	)

	toggle_edit_button.on_button_down.connect(func():
		if room != null:
			room.editable = true
	)

	toggle_edit_button.on_button_up.connect(func():
		if room != null:
			room.editable = false
	)
