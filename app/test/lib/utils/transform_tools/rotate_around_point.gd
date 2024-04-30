extends Node3D

@onready var box = $Box
@onready var box2 = $Box2

func _process(delta):
	var rad = deg_to_rad(20) * delta

	box.global_transform = TransformTools.rotate_around_point_axis(box.global_transform, Vector3(0.5, 0.5, 0.5), Vector3(0, 1, 0), rad)
	box2.global_transform = TransformTools.rotate_around_point(box2.global_transform, Vector3(0.5, 0.5, 0.5), Vector3( - rad, -rad, 0))