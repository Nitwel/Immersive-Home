extends XRCamera3D

@onready var area = $Area3D

var last_room = null

func _ready():
	area.area_entered.connect(func(area: Area3D):
		if HomeApi.has_integration() == false:
			return
		HomeApi.api.integration_handler.set_area_state(area.get_parent().id, true)
	)

	area.area_exited.connect(func(area: Area3D):
		if HomeApi.has_integration() == false:
			return
		HomeApi.api.integration_handler.set_area_state(area.get_parent().id, false)
	)

func _physics_process(_delta):
	if HomeApi.has_integration():
		update_room()

func update_room():
	var room = App.house.find_room_at(global_position)

	if room != last_room:
		if room:
			HomeApi.update_room(room.name)
			last_room = room
		else:
			HomeApi.update_room("outside")
			last_room = null