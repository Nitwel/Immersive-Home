@tool
extends MeshInstance3D
class_name Panel3D

const PanelMaterial = preload ("panel.material")

const COLOR = Color(1.0, 1.0, 1.0, 0.3)
const BORDER_COLOR = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_ACTIVE = Color(0.949, 0.353, 0.22, 0.3)
const BORDER_COLOR_ACTIVE = Color(0.949, 0.353, 0.22, 1.0)
const COLOR_HOVER = Color(0.5, 0.5, 0.5, 0.3)
const BORDER_COLOR_HOVER = Color(0.7, 0.7, 0.7, 1.0)
## Border solid line and inner fade width in meters at border = 1.0
const BORDER_SIZE = 1.0 / 2000.0
const BORDER_FADE_IN = 5.0 / 2000.0

@export var hovering = false:
	set(value):
		hovering = value
		_update_style()

@export var active = false:
	set(value):
		active = value
		_update_style()

@export var size = Vector2(1, 1):
	set(value):
		size = value
		_update_size()

## Corner radius in meters. Clamped to half the shorter side, so a large value
## gives a pill or circle.
@export var corner_radius = 0.006:
	set(value):
		corner_radius = value
		_update_corner_radius()

## Border thickness multiplier for BORDER_SIZE / BORDER_FADE_IN.
@export var border = 0.6:
	set(value):
		border = value
		_update_border()

func _ready():
	mesh = QuadMesh.new()
	material_override = PanelMaterial.duplicate()
	_update_style()
	_update_size()
	_update_corner_radius()
	_update_border()

func _update_border():
	material_override.set_shader_parameter("border_size", border * BORDER_SIZE)
	material_override.set_shader_parameter("border_fade_in", border * BORDER_FADE_IN)

func _update_corner_radius():
	material_override.set_shader_parameter("corner_radius", corner_radius)

func _update_style():
	if active:
		material_override.set_shader_parameter("color", COLOR_ACTIVE)
		material_override.set_shader_parameter("border_color", BORDER_COLOR_ACTIVE)
	elif hovering:
		material_override.set_shader_parameter("color", COLOR_HOVER)
		material_override.set_shader_parameter("border_color", BORDER_COLOR_HOVER)
	else:
		material_override.set_shader_parameter("color", COLOR)
		material_override.set_shader_parameter("border_color", BORDER_COLOR)

func _update_size():
	mesh.size = size
