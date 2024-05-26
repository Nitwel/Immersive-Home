@tool

extends Container3D
class_name ColorPicker3D

signal on_color_changed(color: Color)

@onready var puck = $Puck
@onready var touch_area = $TouchArea
@onready var touch_area_collision = $TouchArea/CollisionShape3D
@onready var collision = $Body/CollisionShape3D
@onready var sprite: Sprite3D = $Body/Sprite3D

var move_plane: Plane

@export var color: Color = Color(1, 1, 1, 1):
	set(value):
		if color != value:
			on_color_changed.emit(value)

		color = value

		if is_node_ready() == false: return

		_update_puck()

func _ready():
	Update.props(self, ["color"])

	move_plane = Plane(Vector3.BACK, Vector3(0, 0, size.z))
	_update()

func _update_puck():
	var coords = _color_to_coords(color) * (size.x / 2.0)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_parallel(true)

	tween.tween_property(puck, "position", Vector3(coords.x, coords.y, size.z), 0.2)
	tween.tween_property(puck.material_override, "albedo_color", color, 0.2)

func _on_press_down(event: EventPointer):
	_handle_press(event)

func _on_press_move(event: EventPointer):
	_handle_press(event)

func _on_touch_enter(event: EventTouch):
	_handle_touch(event)

func _handle_press(event: EventPointer):
	var ray_pos = event.ray.global_position
	var ray_dir = -event.ray.global_transform.basis.z

	var local_pos = to_local(ray_pos)
	var local_dir = global_transform.basis.inverse() * ray_dir

	var click_pos = move_plane.intersects_ray(local_pos, local_dir)
	
	if click_pos == null:
		return

	color = _coords_to_color(Vector2(click_pos.x, click_pos.y) / (size.x / 2.0))

func _handle_touch(event: EventTouch):
	var click_pos = to_local(event.fingers[0].area.global_position)
	
	if click_pos == null:
		return

	color = _coords_to_color(Vector2(click_pos.x, click_pos.y) / (size.x / 2.0))

func _coords_to_color(coords: Vector2) -> Color:
	if coords.length() > 1:
		coords = coords.normalized()

	var hue = (atan2(coords.y, coords.x) + PI) / (2 * PI)
	var saturation = coords.length()
	var value = 1.0

	return Color.from_hsv(hue, saturation, value)

func _color_to_coords(color: Color) -> Vector2:
	var hue = color.h * 2 * PI - PI
	var saturation = color.s
	var coords = Vector2(cos(hue), sin(hue)) * saturation

	return coords

func _generate_color_wheel():
	var image = Image.create(1000, 1000, true, Image.FORMAT_RGBA8)

	for x in range(1000):
		for y in range(1000):
			var delta = Vector2(x, y) / 1000 * 2 - Vector2(1, 1)
			if delta.length() <= 1:
				image.set_pixel(x, y, _coords_to_color(delta))

	ResourceSaver.save(ImageTexture.create_from_image(image), "res://content/ui/components/color_wheel/color_wheel.tres")

func _update():
	sprite.pixel_size = size.x / 1000
	collision.shape.height = size.z
	collision.shape.radius = size.x / 2
	collision.position.z = size.z / 2
	sprite.position.z = size.z
	puck.position.z = size.z
	touch_area_collision.shape.height = size.z + 0.02
	touch_area_collision.shape.radius = size.x / 2
	touch_area_collision.position.z = (size.z + 0.02) / 2
