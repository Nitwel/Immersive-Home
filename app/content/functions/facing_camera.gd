extends Function
class_name FacingCamera

@export var enabled = true
@export var upright = true

func _process(_delta):
	if enabled == false||get_parent().is_inside_tree() == false:
		return

	var basis = Basis.looking_at( - App.camera.global_transform.basis.z, Vector3.UP if upright else App.camera.global_transform.basis.y)
	get_parent().global_transform.basis = basis