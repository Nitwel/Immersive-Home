extends Function
class_name Occludable

var ray := RayCast3D.new()
@onready var player_camera: XRCamera3D = get_node("/root/Main/XROrigin3D/XRCamera3D")

func _ready():
	ray.set_collision_mask_value(1, false)
	ray.set_collision_mask_value(5, true)
	get_parent().add_child.call_deferred(ray)

	EventSystem.on_slow_tick.connect(_slow_tick)

func _slow_tick(_delta):
	if player_camera.is_inside_tree() == false:
		printerr("Player camera is not inside the tree")
		return

	ray.target_position = get_parent().to_local(player_camera.global_position)

	get_parent().visible = ray.is_colliding() == false

