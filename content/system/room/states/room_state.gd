extends State
const Room = preload("res://content/system/room/room.gd")

var room: Room

func _ready():
	room = get_parent().get_parent()
