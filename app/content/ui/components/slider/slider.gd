@tool
extends Node3D
class_name Slider3D

@export var min: float = 0.0:
	set(new_value):
		min = new_value
		if value < min: value = min
		if !is_inside_tree(): return
		
		_update_slider()

@export var max: float = 1.0:
	set(new_value):
		max = new_value
		if value > max: value = max
		if !is_inside_tree(): return

		_update_slider()
			
@export var value: float = 0.2:
	set(new_value):
		value = roundi(clamp(new_value, min, max) / step) * step

		if !is_inside_tree(): return

		label.text = str(value) + " " + label_unit
		if new_value != value: on_value_changed.emit(value)
		_update_slider()

@export var step: float = 0.01

@export var show_label: bool = false:
	set(value):
		show_label = value
		if !is_inside_tree(): return
		label.visible = show_label

@export var label_unit: String = "":
	set(new_value):
		label_unit = new_value
		if !is_inside_tree(): return
		label.text = str(value) + " " + label_unit

@export var size: Vector3 = Vector3(0.2, 0.01, 0.02): # Warning, units are in cm
	set(value):
		size = value
		if !is_inside_tree(): return
		_update_shape()
@export var cutout_border: float = 0.02:
	set(value):
		cutout_border = value
		if !is_inside_tree(): return
		_update_shape()
@export var cutout_depth: float = 0.05:
	set(value):
		cutout_depth = value
		if !is_inside_tree(): return
		_update_shape()

@onready var outside_rod: CSGBox3D = $Rod/Outside
@onready var cutout: CSGCombiner3D = $Rod/Cutout
@onready var cutout_box: CSGBox3D = $Rod/Cutout/Length
@onready var cutout_end_left: CSGCylinder3D = $Rod/Cutout/EndLeft
@onready var cutout_end_right: CSGCylinder3D = $Rod/Cutout/EndRight
@onready var label: Label3D = $Label

@onready var body_collision_shape: CollisionShape3D = $CollisionBody/CollisionShape3D
@onready var area_collision_shape: CollisionShape3D = $Area3D/CollisionShape3D

@onready var slider_knob: MeshInstance3D = $Knob

signal on_value_changed(value: float)

var move_plane: Plane

func _ready():
	Update.props(self, ["value", "show_label", "label_unit"])

	_update_slider()
	_update_shape()
	move_plane = Plane(Vector3.UP, Vector3(0, size.y / 200, 0))

func _on_press_down(event: EventPointer):
	_handle_press(event)

func _on_press_move(event: EventPointer):
	_handle_press(event)

func _on_touch_enter(event: EventTouch):
	_handle_touch(event)

func _get_slider_min_max():
	var cutout_radius = (size.z - cutout_border * 2) / 2

	return Vector2( - size.x / 2 + cutout_border + cutout_radius, size.x / 2 - cutout_border - cutout_radius) / 100

func _handle_press(event: EventPointer):
	var ray_pos = event.ray.global_position
	var ray_dir = -event.ray.global_transform.basis.z

	var local_pos = to_local(ray_pos)
	var local_dir = global_transform.basis.inverse() * ray_dir

	var click_pos = move_plane.intersects_ray(local_pos, local_dir)
	
	if click_pos == null:
		return

	var min_max = _get_slider_min_max()

	var pos_x = clamp(click_pos.x, min_max.x, min_max.y)

	var click_percent = inverse_lerp(min_max.x, min_max.y, pos_x)

	value = lerp(min, max, click_percent)

func _handle_touch(event: EventTouch):

	var click_pos = to_local(event.fingers[0].area.global_position)

	var min_max = _get_slider_min_max()

	var pos_x = clamp(click_pos.x, min_max.x, min_max.y)

	var click_percent = inverse_lerp(min_max.x, min_max.y, pos_x)

	value = lerp(min, max, click_percent)

func _update_slider():
	var min_max = _get_slider_min_max()

	var click_percent = inverse_lerp(min, max, value)

	slider_knob.position.x = lerp(min_max.x, min_max.y, click_percent)

func _update_shape():
	outside_rod.size = size

	body_collision_shape.shape.size = size * 0.01
	area_collision_shape.shape.size = Vector3(size.x, size.y * 2, size.z) * 0.01
	area_collision_shape.position = Vector3(0, size.y, 0) * 0.01

	var cutout_width = size.z - cutout_border * 2

	cutout_box.size = Vector3(
		size.x - cutout_border * 2 - (cutout_width),
		cutout_depth,
		cutout_width
	)

	cutout.position = Vector3(
		0,
		size.y / 2 - cutout_depth / 2 + 0.001,
		0
	)

	cutout_end_left.radius = cutout_box.size.z / 2
	cutout_end_right.radius = cutout_box.size.z / 2
	cutout_end_left.height = cutout_depth
	cutout_end_right.height = cutout_depth

	cutout_end_left.position = Vector3(
		- cutout_box.size.x / 2,
		0,
		0
	)

	cutout_end_right.position = Vector3(
		cutout_box.size.x / 2,
		0,
		0
	)

	label.position = Vector3(
		size.x / 200 + 0.005,
		0,
		0
	)
