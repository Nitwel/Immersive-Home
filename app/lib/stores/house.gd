extends StoreClass
## Stores information about the house, its rooms and entities

const StoreClass = preload ("./store.gd")

func _init():
	_save_path = "user://house.json"

	self.state = R.store({
		## Type Room
		## 	 name: String
		## 	 corners: Vec2[]
		## 	 height: float
		"rooms": [],
		## Type Entity
		##   id: String
		## 	 position: Vec3
		## 	 rotation: Vec3
		## 	 room: String
		##   interface: String
		"entities": [],
		"align_position1": Vector3(),
		"align_position2": Vector3()
	})

func clear():
	self.state.rooms = []
	self.state.entities = []

func get_room(name):
	for room in self.state.rooms:
		if room.name == name:
			return room
	return null