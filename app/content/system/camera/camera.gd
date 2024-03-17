extends XRCamera3D

var last_room = null

func _physics_process(_delta):
	if HomeApi.has_integration():
		update_room()

func update_room():
	var room = House.body.find_room_at(global_position)

	if room != last_room:
		if room:
			HomeApi.update_room(room.name)
			last_room = room
		else:
			HomeApi.update_room("outside")
			last_room = null