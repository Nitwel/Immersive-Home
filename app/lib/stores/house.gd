extends StoreClass
## Stores information about the house, its rooms and entities

const StoreClass = preload ("./store.gd")

## Where the house is saved. The demo mode keeps its own house in DEMO_PATH, so it
## never touches the real one.
const PATH = "user://house.json"
const DEMO_PATH = "user://demo_house.json"

func _init():
	_save_path = PATH

	self.state = R.store(_defaults())

## Switches the file the house is saved in and loaded from. The house in memory is
## reset to an empty one, load_local() then reads the new file.
func use_save_path(path: String):
	if path == _save_path:
		return

	_save_path = path
	_loaded = false

	var defaults = _defaults()
	for key in defaults:
		self.state[key] = defaults[key]

func _defaults() -> Dictionary:
	return {
		## Type Room
		## 	 name: String
		## 	 corners: Vec2[]
		## 	 height: float
		"rooms": [],
		## Type Entity
		##   id: String
		## 	 position: Vec3
		## 	 rotation: Vec3
		## 	 scale: float
		## 	 room: String
		##   interface: String
		"entities": [],
		## Type Door
		##   id: int
		##   room1: String
		##   room2: String
		##   room1_position1: Vec3
		##   room1_position2: Vec3
		##   room2_position1: Vec3
		##   room2_position2: Vec3
		"doors": [],
		"align_position1": Vector3(),
		"align_position2": Vector3(),
		## The persistent spatial anchor the house is saved against, see house_anchor.gd
		"anchor_uuid": "",
		## Where that anchor was (floor position and yaw) in the tracking space the
		## house is saved in.
		"anchor_position": Vector3(),
		"anchor_yaw": 0.0,
		## Content of the QR code the house is linked to, see house_qr.gd
		"qr_text": "",
		## Where that QR code was in the tracking space the house is saved in.
		"qr_transform": Transform3D(),
		## Compass bearing (degrees, clockwise from north) the house's -Z axis points
		## to; turns the miniature on the Map View to match the real house.
		"map_heading": 0.0
	}

func clear():
	self.state.rooms = []
	self.state.entities = []

func get_room(name):
	for room in self.state.rooms:
		if room.name == name:
			return room
	return null