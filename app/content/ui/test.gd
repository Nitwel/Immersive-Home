extends Node3D

@onready var coll = $StaticBody3D/CollisionShape3D
@onready var mesh = $StaticBody3D/MeshInstance3D

@onready var slider = $StaticBody3D/Slider
@onready var slider2 = $StaticBody3D/Slider2
@onready var slider3 = $StaticBody3D/Slider3
@onready var slider4 = $StaticBody3D/Slider4
@onready var slider5 = $StaticBody3D/Slider5
@onready var slider6 = $StaticBody3D/Slider6

func _ready():
	slider.on_value_changed.connect(func(value):
		mesh.mesh.size.x=value
		coll.shape.size.x=value
		mesh.material_override.set_shader_parameter("size", Vector2(mesh.mesh.size.x, mesh.mesh.size.y))
	)
	slider2.on_value_changed.connect(func(value):
		mesh.mesh.size.y=value
		coll.shape.size.y=value
		mesh.material_override.set_shader_parameter("size", Vector2(mesh.mesh.size.x, mesh.mesh.size.y))
	)

	slider3.on_value_changed.connect(func(value):
		mesh.material_override.set_shader_parameter("border_size", value)
	)

	slider4.on_value_changed.connect(func(value):
		mesh.material_override.set_shader_parameter("corner_radius", value)
	)

	slider5.on_value_changed.connect(func(value):
		mesh.material_override.set_shader_parameter("border_fade_in", value)
	)

	slider6.on_value_changed.connect(func(value):
		mesh.material_override.set_shader_parameter("border_fade_out", value)
	)
