extends StaticBody3D

var camera_follower: CameraFollower

@export var entity_id: String
var icon = R.state("question_mark")
var icon_color = R.state(Color(1, 1, 1, 1))
var show_settings = R.state(false)

func _ready():
	var movable = get_node("Movable")
	camera_follower = get_node_or_null("CameraFollower")

	if camera_follower == null:
		camera_follower = CameraFollower.new()
		add_child(camera_follower)
		
	R.effect(func(_args):
		if show_settings.value == true:
			camera_follower.enabled=true
	)

	if movable:
		movable.on_moved.connect(func():
			App.house.save_all_entities()
		)

func set_options(_options):
	return

func get_options():
	return {}

func toggle_settings():
	show_settings.value = !show_settings.value