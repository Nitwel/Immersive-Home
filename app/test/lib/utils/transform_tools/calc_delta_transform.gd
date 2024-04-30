extends Node3D

@onready var source = $Source
@onready var target = $Target
@onready var soruce_point = $SourcePoint
@onready var target_point = $TargetPoint

func _process(delta):
	source.rotate_y(deg_to_rad(10) * delta)
	source.rotate_x(deg_to_rad(20) * delta)
	source.scale = Vector3(1, 1, 1) * 0.75 + Vector3(1, 1, 1) * 0.25 * sin(Time.get_ticks_msec() * 0.001)

	var source_pos = source.global_position
	var source_dir = source.global_transform.basis.z
	var source_up = Vector3.UP
	var target_pos = target.global_position
	var target_dir = target.global_transform.basis.z
	var target_up = Vector3.UP

	target_point.global_position = TransformTools.calc_delta_transform(source_pos, source_dir, source_up, target_pos, target_dir, target_up) * soruce_point.global_position
