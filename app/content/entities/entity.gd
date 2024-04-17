extends StaticBody3D

var entity_id: String
var icon = R.state("question_mark")
var icon_color = R.state(Color(1, 1, 1, 1))

func _ready():
	var movable = get_node("Movable")

	if movable:
		movable.on_moved.connect(func():
			House.body.save_all_entities()
		)
