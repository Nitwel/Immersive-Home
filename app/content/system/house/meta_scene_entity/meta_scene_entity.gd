extends Node3D

const Wall = preload ("res://assets/materials/wall.tres")

var wall_mesh

func setup_scene(entity: OpenXRFbSpatialEntity):
	var name = entity.get_semantic_labels()[0]

	if name == "invisible_wall_face":
		name = "wall_face"

	if name != "wall_face":
		return

	add_to_group("meta_" + name)

	wall_mesh = entity.create_mesh_instance()
	wall_mesh.material_override = Wall
	add_child(wall_mesh)