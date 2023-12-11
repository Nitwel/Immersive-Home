extends Node3D

const wall_corner_scene = preload("./wall_corner.tscn")
const wall_edge_scene = preload("./wall_edge.tscn")

@onready var wall_corners = $WallCorners
@onready var wall_edges = $WallEdges
@onready var wall_mesh = $WallMesh
@onready var wall_collisions = $WallCollisions

@onready var ground = $Ground/Clickable

var moving = null
var editable := true:
	set(value):
		if value == editable:
			return

		editable = value
		if value:
			_start_edit_mode()
		else:
			_end_edit_mode()
var ground_plane = Plane(Vector3.UP, Vector3.ZERO)


func _ready():
	ground.on_click.connect(func(event):
		if !editable:
			return

		add_corner(event.ray.get_collision_point())
	)

func _start_edit_mode():
	wall_corners.visible = true
	wall_edges.visible = true
	wall_mesh.visible = false
	wall_mesh.mesh = null

	for old_coll in wall_collisions.get_children():
		old_coll.queue_free()

func _end_edit_mode():
	wall_corners.visible = false
	wall_edges.visible = false
	wall_mesh.mesh = generate_mesh()

	if wall_mesh.mesh == null:
		return
		
	var collisions = generate_collision(wall_mesh.mesh)

	for collision in collisions:
		var static_body = StaticBody3D.new()
		static_body.set_collision_layer_value(4, true)
		static_body.set_collision_layer_value(5, true)
		static_body.collision_mask = 0
		static_body.add_child(collision)
		wall_collisions.add_child(static_body)
	
	wall_mesh.visible = true

func generate_mesh():
	var corner_count = wall_corners.get_child_count()

	if corner_count < 3:
		return

	var st = SurfaceTool.new()
	var wall_up = Vector3.UP * 3

	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

	for i in range(corner_count):
		var corner = get_corner(i)

		st.add_vertex(corner.position)
		st.add_vertex(corner.position + wall_up)

	var first_corner = get_corner(0)

	st.add_vertex(first_corner.position)
	st.add_vertex(first_corner.position + wall_up)

	st.index()
	st.generate_normals()
	st.generate_tangents()
	var mesh = st.commit()
	
	return mesh

func generate_collision(mesh: ArrayMesh):
	var corner_count = wall_corners.get_child_count()

	if corner_count < 3:
		return

	var collision_shapes: Array[CollisionShape3D] = []

	for i in range(corner_count):
		var corner = get_corner(i)
		var next_corner = get_corner(i + 1)

		var shape = BoxShape3D.new()
		shape.size = Vector3((next_corner.position - corner.position).length(), 3, 0.04)

		var transform = Transform3D()
		var back_vector = (corner.position - next_corner.position).cross(Vector3.UP).normalized() * shape.size.z / 2

		transform.basis = Basis((next_corner.position - corner.position).normalized(), Vector3.UP,  back_vector.normalized())
		transform.origin = corner.position + (next_corner.position - corner.position) / 2 + back_vector + Vector3.UP * shape.size.y / 2

		var collision_shape = CollisionShape3D.new()

		collision_shape.shape = shape
		collision_shape.transform = transform

		collision_shapes.append(collision_shape)
	
	return collision_shapes
		
func add_corner(position: Vector3):
	var corner = wall_corner_scene.instantiate()
	corner.position = position
	
	corner.get_node("Clickable").on_grab_down.connect(func(event):
		if !editable:
			return

		moving = event.target
	)

	corner.get_node("Clickable").on_grab_move.connect(func(event):
		if moving == null:
			return

		var direction = -event.ray.global_transform.basis.z
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

func _save():
	return {
		"corners": wall_corners.get_children().map(func(corner): return corner.position),
	}

func _load(data):
	for corner in data["corners"]:
		add_corner(corner)

	_end_edit_mode()
