extends RoomState

const wall_corner_scene = preload("../wall_corner.tscn")
const wall_edge_scene = preload("../wall_edge.tscn")
const RoomState = preload("./room_state.gd")

var moving = null
var deleting: bool = false
var floor_corner: StaticBody3D = null
var height_corner: StaticBody3D = null
var height_edge: StaticBody3D = null

func _on_enter():
	room.wall_corners.visible = true
	room.wall_edges.visible = true

	if floor_corner != null:
		floor_corner.visible = true
		height_corner.visible = true
		height_edge.visible = true

	room.room_ceiling.get_node("CollisionShape3D").disabled = (floor_corner == null && height_corner == null)

	var ceiling_shape = WorldBoundaryShape3D.new()
	ceiling_shape.plane = Plane(Vector3.DOWN, 0)
	
	room.room_ceiling.get_node("CollisionShape3D").shape = ceiling_shape
	room.room_floor.get_node("CollisionShape3D").shape = WorldBoundaryShape3D.new()
	
	room.room_ceiling.get_node("Clickable").on_click.connect(_on_click_ceiling)
	room.room_floor.get_node("Clickable").on_click.connect(_on_click_floor)

func _on_leave():
	room.wall_corners.visible = false
	room.wall_edges.visible = false
	
	if floor_corner != null:
		floor_corner.visible = false
		height_corner.visible = false
		height_edge.visible = false

	room.room_ceiling.get_node("Clickable").on_click.disconnect(_on_click_ceiling)
	room.room_floor.get_node("Clickable").on_click.disconnect(_on_click_floor)

func _on_click_floor(event):
	if floor_corner != null && height_corner != null:
		return

	add_floor_corner(event.ray.get_collision_point())
	add_height_corner(event.ray.get_collision_point())
	room.room_ceiling.get_node("CollisionShape3D").disabled = false

func _on_click_ceiling(event):
	if floor_corner == null || height_corner == null || event.target != room.room_ceiling:
		return

	var pos = event.ray.get_collision_point()
	pos.y = 0

	add_corner(pos)

func add_floor_corner(position: Vector3):
	floor_corner = wall_corner_scene.instantiate()
	floor_corner.position = position

	height_edge = wall_edge_scene.instantiate()
	height_edge.align_to_corners(position, position + Vector3.UP * room.room_ceiling.global_position.y)

	floor_corner.get_node("Clickable").on_grab_down.connect(func(event):
		if !is_active() || moving != null:
			return

		moving = event.target
	)

	floor_corner.get_node("Clickable").on_grab_move.connect(func(event):
		if moving == null:
			return

		var moving_index = height_corner.get_index()
		var direction = -event.ray.global_transform.basis.z
		var new_position = room.room_floor.get_node("CollisionShape3D").shape.plane.intersects_ray(event.ray.global_position, direction)

		if new_position == null:
			return

		moving.position = new_position

		height_edge.align_to_corners(new_position, new_position + Vector3.UP * room.room_ceiling.global_position.y)

		room.get_corner(moving_index).position.x = new_position.x
		room.get_corner(moving_index).position.z = new_position.z

		if room.wall_edges.get_child_count() == 0:
			return

		room.get_edge(moving_index).align_to_corners(new_position, room.get_corner(moving_index + 1).position)
		room.get_edge(moving_index - 1).align_to_corners(room.get_corner(moving_index - 1).position, new_position)	
	)

	floor_corner.get_node("Clickable").on_grab_up.connect(func(_event):
		moving = null
	)
	
	room.add_child(floor_corner)
	room.add_child(height_edge)

func add_height_corner(position: Vector3):
	height_corner = wall_corner_scene.instantiate()
	height_corner.position.x = position.x
	height_corner.position.z = position.z

	height_corner.get_node("Clickable").on_grab_down.connect(func(event):
		if !is_active() || moving != null:
			return

		moving = event.target
	)

	height_corner.get_node("Clickable").on_grab_move.connect(func(event):
		if moving == null:
			return

		var direction = -event.ray.global_transform.basis.z
		var plane_direction = direction
		plane_direction.y = 0
		plane_direction = plane_direction.normalized() * -1

		var plane = Plane(plane_direction, moving.position)

		var new_position = plane.intersects_ray(event.ray.global_position, direction)

		if new_position == null:
			return

		room.room_ceiling.position.y = new_position.y
		height_edge.align_to_corners(floor_corner.global_position, height_corner.global_position)
		
	)

	height_corner.get_node("Clickable").on_grab_up.connect(func(_event):
		moving = null
	)

	room.wall_corners.add_child(height_corner)

func add_corner(position: Vector3, index: int = -1):
	var corner = wall_corner_scene.instantiate()
	corner.position.x = position.x
	corner.position.z = position.z
	
	corner.get_node("Clickable").on_grab_down.connect(func(event):
		if !is_active() || moving != null:
			return

		moving = event.target
	)

	corner.get_node("Clickable").on_grab_move.connect(func(event):
		if moving == null:
			return

		var moving_index = moving.get_index()
		var direction = -event.ray.global_transform.basis.z
		var ceiling_plane = Plane(Vector3.DOWN, room.room_ceiling.global_position)
		var new_position = ceiling_plane.intersects_ray(event.ray.global_position, direction)

		if new_position == null:
			deleting = true

			new_position = event.ray.global_position + direction

			room.get_corner(moving_index).global_position = new_position

			if room.wall_edges.get_child_count() == 0:
				return

			room.get_edge(moving_index).align_to_corners(room.get_corner(moving_index - 1).position, room.get_corner(moving_index + 1).position)
			room.get_edge(moving_index - 1).transform = room.get_edge(moving_index).transform

			return

		deleting = false

		new_position.y = 0

		moving.position = new_position
		

		if room.wall_edges.get_child_count() == 0:
			return

		room.get_edge(moving_index).align_to_corners(new_position, room.get_corner(moving_index + 1).position)
		room.get_edge(moving_index - 1).align_to_corners(room.get_corner(moving_index - 1).position, new_position)	
	)

	corner.get_node("Clickable").on_grab_up.connect(func(_event):
		if deleting:
			var moving_index = moving.get_index()
			room.remove_corner(moving_index)

		moving = null
		deleting = false
	)
	
	room.wall_corners.add_child(corner)
	room.wall_corners.move_child(corner, index)

	var num_corners = room.wall_corners.get_child_count()

	if num_corners > 1:
		add_edge(position, room.get_corner(index + 1).position, index)

	if num_corners > 2:
		if num_corners != room.wall_edges.get_child_count():
			add_edge(room.get_corner(-2).position, room.get_corner(-1).position, -2)
		else:
			room.get_edge(index - 1).align_to_corners(room.get_corner(index - 1).position, position)
			

func add_edge(from_pos: Vector3, to_pos: Vector3, index: int = -1):
	var edge: StaticBody3D = wall_edge_scene.instantiate()
	edge.align_to_corners(from_pos, to_pos)

	edge.get_node("Clickable").on_press_down.connect(func(event):
		var point = event.ray.get_collision_point()
		point.y = 0
		add_corner(point, edge.get_index() + 1)
	)


	room.wall_edges.add_child(edge)
	room.wall_edges.move_child(edge, index)
	return edge