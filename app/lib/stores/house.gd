extends StoreClass
## Stores information about the house, its rooms and entities

const StoreClass = preload ("./store.gd")

## Type Room
## 	name: String
## 	corners: Vec2[]
## 	height: float
var rooms = []
## Type Entity
##   id: String
## 	position: Vec3
## 	rotation: Vec3
## 	room: String
var entities = []
var align_position1: Vector3
var align_position2: Vector3

func _init():
	_save_path = "user://house.json"

func clear():
	rooms = []
	entities = []

func get_room(name):
	for room in rooms:
		if room.name == name:
			return room
	return null