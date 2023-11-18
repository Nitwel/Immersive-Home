extends Node3D

const wall_corner_scene = preload("res://content/ui/menu/room/wall_corner.tscn")
const wall_edge_scene = preload("res://content/ui/menu/room/wall_edge.tscn")

@onready var teleport_root = $TeleportRoot
@onready var wall_corners = $TeleportRoot/WallCorners
@onready var wall_edges = $TeleportRoot/WallEdges
@onready var wall_mesh = $TeleportRoot/WallMesh
@onready var toggle_edit_button = $Interface/ToggleEdit

var moving = null
var ground_plane = Plane(Vector3.UP, Vector3.ZERO)
var edit_enabled = false

func _ready():
	remove_child(teleport_root)
	get_tree().get_root().get_node("Main").add_child.call_deferred(teleport_root)

	teleport_root.get_node("Ground/Clickable").on_click.connect(func(event):
		if !edit_enabled:
			return

		add_corner(event.ray.get_collision_point())
	)

	toggle_edit_button.get_node("Clickable").on_click.connect(func(event):
		edit_enabled = event.active

		if edit_enabled == false:
			wall_corners.visible = false
			wall_edges.visible = false
			generate_mesh()
			wall_mesh.visible = true
		else:
			wall_corners.visible = true
			wall_edges.visible = true
			wall_mesh.visible = false
	)

func generate_mesh():
	var st = SurfaceTool.new()
	var wall_up = Vector3.UP * 3

	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

	for i in range(wall_corners.get_child_count()):
		var corner = get_corner(i)

		print(corner.position, " ", corner.position + wall_up)

		st.add_vertex(corner.position)
		st.add_vertex(corner.position + wall_up)

	var first_corner = get_corner(0)

	st.add_vertex(first_corner.position)
	st.add_vertex(first_corner.position + wall_up)

	st.index()
	st.generate_normals()
	st.generate_tangents()
	var mesh = st.commit()
	
	wall_mesh.mesh = mesh
		
func add_corner(position: Vector3):
	var corner = wall_corner_scene.instantiate()
	corner.position = position
	
	corner.get_node("Clickable").on_grab_down.connect(func(event):
		if !edit_enabled:
			return

		moving = event.target
	)

	corner.get_node("Clickable").on_grab_move.connect(func(event):
		if moving == null:
			return

		var direction = (event.ray.to_global(event.ray.target_position) - event.ray.global_position).normalized()
		var new_position = ground_plane.intersects_ray(event.ray.global_position, direction)

		if new_position == null:
			return

		moving.position = new_position
		var moving_index = moving.get_index()

		get_edge(moving_index).transform = corners_to_edge_transform(new_position, get_corner(moving_index + 1).position)
		get_edge(moving_index - 1).transform = corners_to_edge_transform(get_corner(moving_index - 1).position, new_position)	
	)

	corner.get_node("Clickable").on_grab_up.connect(func(_event):
		moving = null
	)
	
	wall_corners.add_child(corner)


	var num_corners = wall_corners.get_child_count()
	var edge

	if num_corners > 1:
		edge = add_edge(wall_corners.get_child(num_corners - 2).position, position)

	if num_corners > 2:		
		if num_corners != wall_edges.get_child_count():
			add_edge(position, wall_corners.get_child(0).position)
		else:
			wall_edges.move_child(edge, num_corners - 2)
			get_edge(-1).transform = corners_to_edge_transform(position, get_corner(0).position)

func get_corner(index: int) -> MeshInstance3D:
	return wall_corners.get_child(index % wall_corners.get_child_count())

func get_edge(index: int) -> MeshInstance3D:
	return wall_edges.get_child(index % wall_edges.get_child_count())


func add_edge(from_pos: Vector3, to_pos: Vector3):
	var edge: MeshInstance3D = wall_edge_scene.instantiate()
	edge.transform = corners_to_edge_transform(from_pos, to_pos)
	wall_edges.add_child(edge)
	return edge

func corners_to_edge_transform(from_pos: Vector3, to_pos: Vector3) -> Transform3D:
	var diff = to_pos - from_pos
	var direction = diff.normalized()

	var edge_position = from_pos + diff / 2
	var edge_basis = Basis(Vector3.UP, diff, direction.cross(Vector3.UP))

	var edge_transform = Transform3D(edge_basis, edge_position)
	return edge_transform
