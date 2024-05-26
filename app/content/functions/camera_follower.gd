extends Function
class_name CameraFollower

@export var enabled = true:
	set(value):
		enabled = value
		if enabled:
			_update_initial_transform()
			EventSystem.on_slow_tick.connect(_slow_tick)
		else:
			EventSystem.on_slow_tick.disconnect(_slow_tick)

@export var focus_point: Node3D = null

var next_new_transform = null
var initial_transform = null

func _ready():
	next_new_transform = get_parent().global_transform
	_update_initial_transform()
	
func _update_initial_transform():
	if get_parent() == null||get_parent().is_inside_tree() == false:
		return

	initial_transform = get_parent().global_transform

func reset():
	enabled = false
	if initial_transform != null:
		get_parent().global_transform = initial_transform

func reset_animated():
	enabled = false
	if initial_transform == null:
		var tween = create_tween()
		tween.set_trans(Tween.TransitionType.TRANS_QUAD)
		tween.tween_property(get_parent(), "global_transform", initial_transform, 0.6)

func _slow_tick(delta):
	if get_parent().is_inside_tree() == false:
		return

	var new_transform = App.camera.global_transform.translated_local(Vector3(0, 0, -0.5))

	if focus_point != null:
		new_transform = new_transform * (get_parent().global_transform.affine_inverse() * focus_point.global_transform).affine_inverse()
		
	if next_new_transform.origin.distance_to(new_transform.origin) > 0.2:
		next_new_transform = new_transform

		var tween = create_tween()
		tween.set_parallel(true)
		tween.set_trans(Tween.TransitionType.TRANS_QUAD)
		tween.tween_property(get_parent(), "global_transform", new_transform, 0.6)