extends StaticBody3D

var entity_id: String

func _ready():
	var movable = get_node("Movable")

	if movable:
		movable.on_moved.connect(func():
			House.body.save_all_entities()
		)
