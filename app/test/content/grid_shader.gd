@tool
extends Node3D

const GridShader = preload ("res://assets/materials/grid.tres")

@onready var mesh = $MeshInstance3D

func _process(_delta):
	GridShader.set_shader_parameter("dot_offset", TransformTools.plane_2d_coords(mesh.global_transform))