extends Node3D
## Draws each shader of the Map View once, tiny and invisible in front of the camera,
## so the headset compiles them at startup instead of in a hitch the first time the
## Map View opens. Frees itself after a few frames.
##
## Add it to the camera once XR runs: on the headset the shaders are compiled for
## stereo rendering, which differs from the flat view before. In the Compatibility
## renderer a shader is compiled per draw mode, so the meshes match the real ones:
## opaque and fading (transparent) variants, instanced trees (MultiMesh), and the
## buildings' vertex format.

const MapView = preload ("res://content/entities/person/map_view.gd")
const Map3D = preload ("res://content/entities/person/map_3d.gd")
const PathOverlay = preload ("res://content/entities/person/path_overlay.gd")
const Dollhouse = preload ("res://content/system/miniature/dollhouse.gd")

## Frames to keep drawing before freeing (shaders compile on the first draw)
const FRAMES = 30

var _frames := 0

func _ready():
	# In front of the camera (the parent), far too small to see
	position = Vector3(0, 0, -0.5)
	scale = Vector3.ONE * 0.0005

	# Flat map: opaque and fading
	var map_material = ShaderMaterial.new()
	map_material.shader = MapView.MapShader
	_add_mesh(QuadMesh.new(), map_material)
	var map_fade_material = ShaderMaterial.new()
	map_fade_material.shader = MapView.MapFadeShader
	map_fade_material.render_priority = 11
	_add_mesh(QuadMesh.new(), map_fade_material)

	# Map markers (a disc and its label)
	var marker = MapView.create_marker_node()
	MapView.apply_marker(marker, {"text": "A"})
	add_child(marker)

	# Paths and building outlines
	var path_mesh = PathOverlay.build([{"points": PackedVector3Array([Vector3.ZERO, Vector3(1, 0, 0)]), "color": Color.WHITE}], Vector3.BACK, 0.2, 0.2)
	_add_mesh(path_mesh, PathOverlay.material(false))
	_add_mesh(path_mesh, PathOverlay.material(true))

	# 3D map: terrain, buildings and trees, opaque and fading
	var diorama = Map3D._material(Color.WHITE)
	_add_mesh(QuadMesh.new(), diorama)
	_add_mesh(_building_mesh(), diorama)
	var trees = MultiMeshInstance3D.new()
	trees.multimesh = MultiMesh.new()
	trees.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	trees.multimesh.mesh = CylinderMesh.new()
	trees.multimesh.instance_count = 1
	trees.material_override = diorama
	add_child(trees)
	var diorama_fade = Map3D._material(Color.WHITE)
	diorama_fade.shader = Map3D.DioramaFadeShader
	_add_mesh(QuadMesh.new(), diorama_fade)

	# Dollhouse: floors, walls, shadows, room names and a light's dot
	var dollhouse = Dollhouse.new()
	add_child(dollhouse)
	dollhouse.build([{"name": "Warmup", "height": 2.5, "corners": [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]}], [], [])
	dollhouse.set_view(1.0, 1.0, null)
	_hide_labels(dollhouse)
	var dot_material = StandardMaterial3D.new()
	dot_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_add_mesh(SphereMesh.new(), dot_material)

func _process(_delta):
	_frames += 1
	if _frames >= FRAMES:
		queue_free()

func _add_mesh(mesh: Mesh, material: Material):
	var instance = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	add_child(instance)

## A triangle in the 3D map's building format: colours, UV2 and CUSTOM0 (outlines).
static func _building_mesh() -> ArrayMesh:
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([Vector3.ZERO, Vector3(1, 0, 0), Vector3(0, 1, 0)])
	arrays[Mesh.ARRAY_COLOR] = PackedColorArray([Color.WHITE, Color.WHITE, Color.WHITE])
	arrays[Mesh.ARRAY_TEX_UV2] = PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])
	arrays[Mesh.ARRAY_CUSTOM0] = PackedFloat32Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, [], {}, Mesh.ARRAY_CUSTOM_RGBA_FLOAT << Mesh.ARRAY_FORMAT_CUSTOM0_SHIFT)
	return mesh

## The room names keep their size on screen however small the dollhouse is: drawn,
## but fully transparent.
static func _hide_labels(node: Node):
	for child in node.get_children():
		if child is Label3D:
			child.modulate.a = 0.0
			child.outline_modulate.a = 0.0
		_hide_labels(child)
