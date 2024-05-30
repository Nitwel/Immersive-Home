@tool
extends Container3D
class_name Slider3D

signal on_value_changed(value: float)

var throttled_value_changed = ProcessTools.throttle_bouce(func(value: float):
	on_value_changed.emit(value)
, 500)

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
		if new_value != value: throttled_value_changed.call(value)
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

@onready var label: Label3D = $Label

@onready var mesh: MeshInstance3D = $Body/MeshInstance3D
@onready var body_collision_shape: CollisionShape3D = $Body/CollisionShape3D
@onready var area_collision_shape: CollisionShape3D = $Area3D/CollisionShape3D
@onready var slider_knob: MeshInstance3D = $Knob

var move_plane: Plane

func _ready():
	Update.props(self, ["value", "show_label", "label_unit"])

	_update_slider()
	_update()
	move_plane = Plane(Vector3.BACK, Vector3(0, 0, size.z))

func _on_press_down(event: EventPointer):
	_handle_press(event)

func _on_press_move(event: EventPointer):
	_handle_press(event)

func _on_touch_enter(event: EventTouch):
	_handle_touch(event)

func _get_slider_min_max():
	return Vector2( - size.x / 2 + 0.01, size.x / 2 - 0.01)

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

func _update():
	_update_slider()
	body_collision_shape.shape.size = size
	body_collision_shape.position = Vector3(0, 0, size.z / 2)

	area_collision_shape.shape.size = Vector3(size.x, size.y, 0.01)
	area_collision_shape.position = Vector3(0, 0, size.z + 0.005)

	mesh.position = Vector3(0, 0, size.z)
	mesh.mesh.size = Vector2(size.x, size.y)
	mesh.material_override.set_shader_parameter("size", Vector2(size.x, size.y) * 10.0)

	slider_knob.position.z = size.z + 0.002
	slider_knob.mesh.size = Vector2(size.y * 0.75, size.y * 0.75)
	slider_knob.material_override.set_shader_parameter("size", Vector2(size.y * 7.5, size.y * 7.5))

	label.position = Vector3(size.x / 2 + 0.005, 0, size.z)