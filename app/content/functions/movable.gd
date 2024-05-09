@tool
extends Function
class_name Movable

signal on_move(position: Vector3, rotation: Vector3)
signal on_moved()

@export var restricted: bool = false
@export var resizable: bool = false
@export var lock_rotation: bool = false
@export var restrict_movement: Callable
@export var disabled: bool = false

var initiator = null
var initiator2 = null

var relative_transform = Transform3D()
var initial_point = Vector3()
var initial_rotation = Vector3()

# For Scaling
var initial_position = Vector3()
var initial_direction = Vector3()
var initial_up = Vector3()
var initial_transform = Transform3D()
var distances = Vector2()

func _process(delta):
	if get_tree().debug_collisions_hint&&initiator2 != null:
		DebugDraw3D.draw_line(initial_position, initial_position + initial_direction, Color(1, 0, 0))
		DebugDraw3D.draw_line(initial_position, initial_position + initial_up, Color(0, 1, 0))

func _on_grab_down(event: EventPointer):
	if disabled:
		return

	if restricted&&event.target != get_parent():
		return

	if initiator != null&&initiator2 != null:
		return

	if initiator != null&&initiator2 == null&&initiator != event.initiator:
		initiator2 = event.initiator

		distances.y = event.ray.get_collision_point().distance_to(event.ray.global_position)

		initial_position = _get_first_ray_point()
		initial_direction = _get_second_ray_point() - initial_position
		initial_up = -initiator.node.global_transform.basis.z.normalized() * distances.x
		initial_transform = get_parent().global_transform

		return

	distances.x = event.ray.get_collision_point().distance_to(event.ray.global_position)

	initiator = event.initiator

	_update_relative_transform()

	if lock_rotation:
		initial_point = get_parent().to_local(event.ray.get_collision_point())
		initial_rotation = get_parent().global_rotation

func _on_grab_move(event: EventPointer):
	if event.initiator != initiator:
		return

	if initiator != null&&initiator2 != null:
		var new_position = _get_first_ray_point()
		var new_direction = _get_second_ray_point() - new_position
		var new_up = -initiator.node.global_transform.basis.z.normalized() * distances.x

		if resizable == false:
			new_direction = new_direction.normalized() * initial_direction.length()

		if get_tree().debug_collisions_hint:
			DebugDraw3D.draw_line(new_position, new_position + new_direction, Color(1, 0, 0))
			DebugDraw3D.draw_line(new_position, new_position + new_up, Color(0, 1, 0))

		get_parent().global_transform = TransformTools.calc_delta_transform(initial_position, initial_direction, initial_up, new_position, new_direction, new_up) * initial_transform
		return

	get_parent().global_transform = initiator.node.global_transform * relative_transform

	if lock_rotation:
		get_parent().global_transform = TransformTools.rotate_around_point(get_parent().global_transform, get_parent().to_global(initial_point), initial_rotation - get_parent().global_rotation)

	if restrict_movement:
		get_parent().global_position = restrict_movement.call(get_parent().global_position)
	on_move.emit(get_parent().global_position, get_parent().global_rotation)

func _on_grab_up(event: EventPointer):
	if event.initiator == initiator2:
		initiator2 = null
		_update_relative_transform()
		return

	if event.initiator == initiator:
		if initiator2 != null:
			initiator = initiator2
			initiator2 = null
			_update_relative_transform()
		else:
			initiator = null
			initiator2 = null
			on_moved.emit()

func _get_first_ray_point():
	if initiator == null:
		return Vector3()

	return initiator.node.global_position - initiator.node.global_transform.basis.z.normalized() * distances.x

func _get_second_ray_point():
	if initiator2 == null:
		return Vector3()

	return initiator2.node.global_position - initiator2.node.global_transform.basis.z.normalized() * distances.y

func _update_relative_transform():
	relative_transform = initiator.node.global_transform.affine_inverse() * get_parent().global_transform

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	if get_parent() is StaticBody3D == false:
		warnings.append("Movable requires a StaticBody3D as parent.")

	return warnings
