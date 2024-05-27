@tool
extends Node3D

const FontTools = preload ("res://lib/utils/font_tools.gd")

@onready var label = $Body/Label3D
@onready var collision = $Body/CollisionShape3D
@onready var area_collision = $Area3D/CollisionShape3D

var text = "test"
var value = ""
var disabled = false:
	set(value):
		disabled = value

		if is_node_ready() == false: return

		collision.disabled = value
		area_collision.disabled = value

func _ready():
	label.text = text

	_update()

func get_size() -> Vector2:
	return FontTools.get_font_size(label)

func _update():
	var size = get_size()
	collision.shape.size = Vector3(size.x, size.y, 0.004)
	area_collision.shape.size = Vector3(size.x, size.y, 0.01)
	collision.position = Vector3(size.x / 2, -size.y / 2, 0.002)
	area_collision.position = Vector3(size.x / 2, -size.y / 2, 0.005)