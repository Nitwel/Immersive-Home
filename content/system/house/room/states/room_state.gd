extends State
const Room = preload("res://content/system/house/room/room.gd")

var room: Room

func _ready():
	room = get_parent().get_parent()
