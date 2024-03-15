@tool
extends Node3D

const material: StandardMaterial3D = preload ("res://assets/materials/pri-500.material")
var time: float = 0.0
const DOT_COUNT = 8
const RADIUS = 0.025

func _ready():
	generate_meshes()

func generate_meshes():
	for i in range(DOT_COUNT):
		var mesh := MeshInstance3D.new()
		mesh.mesh = CylinderMesh.new()
		mesh.mesh.top_radius = 0.005
		mesh.mesh.bottom_radius = 0.005
		mesh.mesh.height = 0.005
		mesh.material_override = material.duplicate()
		mesh.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

		add_child(mesh)

		mesh.position = Vector3(sin(i * PI / DOT_COUNT * 2), cos(i * PI / DOT_COUNT * 2), 0) * RADIUS
		mesh.rotation_degrees = Vector3(90, 0, 0)

func _process(delta):
	if !visible:
		return

	time += delta

	for i in range(get_child_count()):
		var mesh := get_child(i)

		if mesh == null:
			return

		mesh.material_override.albedo_color.a = saw_tooth(i / float(get_child_count()) + time)

func saw_tooth(x: float) -> float:
	return 1 - fmod(x, 1)