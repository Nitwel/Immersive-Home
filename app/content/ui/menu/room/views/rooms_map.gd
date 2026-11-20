extends Node3D
## The house's floor plan in the Room setup menu, seen from above: each room in the
## same colour as on the Map View's dollhouse (dollhouse.gd), outlined like its
## walls and named, and the doors between them. Lies in this node's XY plane, facing
## +Z, centred on it and fitted into [member size].
##
## In [constant Mode.ROOMS] rooms can be selected, in [constant Mode.DOORS] doors (the
## rooms are drawn dimmer behind them), in [constant Mode.VIEW] nothing.

const Dollhouse = preload ("res://content/system/miniature/dollhouse.gd")
const UI = preload ("res://content/entities/entity_ui.gd")

enum Mode {ROOMS, DOORS, VIEW}

## Edge length (meters) of the square the plan is fitted into
@export var size := 0.2
@export var mode: Mode = Mode.ROOMS

const OUTLINE = 0.0016
const SELECTED_OUTLINE = 0.0028
const OUTLINE_COLOR = Dollhouse.CAP_COLOR
const ACCENT = Color(0.949, 0.353, 0.22)
## Doors are at least this thick on the plan (they're often only a wall's depth)
const DOOR_MIN_DEPTH = 0.004
## Doors can be picked within this distance, they'd be hard to hit otherwise
const DOOR_HIT_DEPTH = 0.014
const LABEL_COLOR = Color(0.12, 0.12, 0.14)

var selectable = R.state(true)
var selected_room = R.state(null)
var selected_door = R.state(null)

## room name -> {body, fill: StandardMaterial3D, outline: MeshInstance3D, color}
var _rooms := {}
## door id -> {body, fill: StandardMaterial3D}
var _doors := {}
var _content := Node3D.new()

func _ready():
	add_child(_content)

	R.effect(func(_arg):
		_build(Store.house.state.rooms, Store.house.state.doors)
		# Shows the current selection on the fresh plan; untracked, see below.
		_update_selection.call_deferred()
	)

	R.effect(func(_arg):
		selected_room.value
		selected_door.value
		_update_selection()
	)

func _build(rooms: Array, doors: Array):
	for child in _content.get_children():
		_content.remove_child(child)
		child.queue_free()
	_rooms.clear()
	_doors.clear()

	var plans = {}
	var bounds = null
	for room in rooms:
		var corners = _corners(room.corners)
		if corners.size() < 3:
			continue
		plans[room.name] = corners
		for corner in corners:
			bounds = Rect2(corner, Vector2.ZERO) if bounds == null else bounds.expand(corner)
	if bounds == null:
		UI.label(_content, "No rooms yet", 12, Vector3(0, 0, 0.003), HORIZONTAL_ALIGNMENT_CENTER).modulate = Color(1, 1, 1, 0.6)
		return

	# House meters to plan meters: north up, east right, centred.
	var house_scale = size / max(bounds.size.x, bounds.size.y, 0.01)
	var center = bounds.get_center()
	var to_plan = func(point: Vector2) -> Vector2:
		return Vector2(point.x - center.x, center.y - point.y) * house_scale

	var index = 0
	for room_name in plans:
		var corners = PackedVector2Array()
		for corner in plans[room_name]:
			corners.append(to_plan.call(corner))
		_add_room(str(room_name), corners, index)
		index += 1

	if mode == Mode.DOORS:
		for door in doors:
			var points = [door.room1_position1, door.room1_position2, door.room2_position2, door.room2_position1].map(func(p):
				return to_plan.call(Vector2(p.x, p.z))
			)
			_add_door(door.id, points)

func _add_room(room_name: String, corners: PackedVector2Array, index: int):
	var color = Dollhouse._room_color(room_name)
	var body = StaticBody3D.new()
	body.set_meta("room", room_name)
	body.set_collision_layer_value(1, false)
	body.set_collision_layer_value(2, mode == Mode.ROOMS)
	# Where rooms overlap, the later one is drawn on top.
	body.position.z = index * 0.0001
	_content.add_child(body)

	var fill = _material(color)
	var floor_mesh = MeshInstance3D.new()
	floor_mesh.mesh = _polygon_mesh(corners)
	floor_mesh.material_override = fill
	body.add_child(floor_mesh)

	var outline = MeshInstance3D.new()
	outline.material_override = _material(OUTLINE_COLOR)
	outline.position.z = 0.001
	body.add_child(outline)

	if mode == Mode.ROOMS:
		var collision = CollisionPolygon3D.new()
		collision.polygon = corners
		collision.depth = 0.004
		body.add_child(collision)

	# The name in the room's largest rectangle-ish part: the bounding box of an L-shaped
	# room has its middle outside the room, maybe in a neighbour.
	var area = _label_area(corners)
	var label = UI.label(body, room_name, 11, Vector3(area.get_center().x, area.get_center().y, 0.003), HORIZONTAL_ALIGNMENT_CENTER)
	label.modulate = LABEL_COLOR
	UI.fit_label(label, room_name, area.size.x * 0.9)
	# Too small a room to fit any of its name
	label.visible = area.size.y > 0.012 and area.size.x > 0.02

	_rooms[room_name] = {"body": body, "fill": fill, "outline": outline, "color": color, "corners": corners, "label": label}

func _add_door(id, points: Array):
	var center = (points[0] + points[1] + points[2] + points[3]) / 4.0
	var along: Vector2 = points[1] - points[0]
	var width = along.length()
	if width < 0.0005:
		return
	along /= width
	var across = Vector2(-along.y, along.x)
	var depth = max(abs((points[3] - points[0]).dot(across)), DOOR_MIN_DEPTH)

	var body = StaticBody3D.new()
	body.set_meta("door", id)
	body.set_collision_layer_value(1, false)
	body.set_collision_layer_value(2, true)
	body.position = Vector3(center.x, center.y, 0.002)
	body.rotation.z = along.angle()
	_content.add_child(body)

	var fill = _material(Dollhouse.DOOR_COLOR)
	var mesh = MeshInstance3D.new()
	mesh.mesh = QuadMesh.new()
	mesh.mesh.size = Vector2(width, depth)
	mesh.material_override = fill
	body.add_child(mesh)

	var collision = CollisionShape3D.new()
	collision.shape = BoxShape3D.new()
	collision.shape.size = Vector3(width, max(depth, DOOR_HIT_DEPTH), 0.004)
	body.add_child(collision)

	_doors[id] = {"body": body, "fill": fill}

## Highlights the selected room or door: its outline in the accent colour; the
## other rooms dimmed while something is selected or doors are being picked.
func _update_selection():
	var room = selected_room.value if mode == Mode.ROOMS else null
	var door = selected_door.value if mode == Mode.DOORS else null
	for room_name in _rooms:
		var entry = _rooms[room_name]
		var is_selected = room_name == str(room) if room != null else false
		var dim = mode == Mode.DOORS or (room != null and not is_selected)
		entry.fill.albedo_color = _dimmed(entry.color) if dim else entry.color
		entry.label.modulate = Color(LABEL_COLOR, 0.5 if dim else 1.0)
		entry.outline.mesh = _outline_mesh(entry.corners, SELECTED_OUTLINE if is_selected else OUTLINE)
		entry.outline.material_override.albedo_color = ACCENT if is_selected else OUTLINE_COLOR
		# On top of the neighbours' outlines
		entry.outline.position.z = 0.0015 if is_selected else 0.001
	for id in _doors:
		_doors[id].fill.albedo_color = ACCENT if door != null and id == door else Color.WHITE

func _on_click(event: EventPointer):
	if selectable.value == false or not (event.target is Node):
		return
	if mode == Mode.ROOMS and event.target.has_meta("room"):
		var room_name = event.target.get_meta("room")
		selected_room.value = null if selected_room.value == room_name else room_name
	elif mode == Mode.DOORS and event.target.has_meta("door"):
		var door_id = event.target.get_meta("door")
		selected_door.value = null if selected_door.value == door_id else door_id

## The plan's node of a room, or null if there is no such room.
func get_room(room_name):
	if room_name == null or not _rooms.has(str(room_name)):
		return null
	return _rooms[str(room_name)].body

## Colour of a room on the plan (and the Map View).
static func room_color(room_name: String) -> Color:
	return Dollhouse._room_color(room_name)

static func _dimmed(color: Color) -> Color:
	return color.lerp(Color(0.42, 0.43, 0.46), 0.55)

static func _material(color: Color) -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = color
	return material

## Room corners without repeats, counter-clockwise, in house meters (x, z).
static func _corners(points: Array) -> PackedVector2Array:
	var corners = PackedVector2Array()
	for point in points:
		var corner = Vector2(point.x, point.y)
		if corners.is_empty() or corners[-1].distance_to(corner) > 0.01:
			corners.append(corner)
	if corners.size() > 1 and corners[0].distance_to(corners[-1]) <= 0.01:
		corners.remove_at(corners.size() - 1)
	return corners

## Where a room's name goes: its bounding box if the room fills most of it, else the
## largest box within the room found on a grid over it.
static func _label_area(corners: PackedVector2Array) -> Rect2:
	var bounds = Rect2(corners[0], Vector2.ZERO)
	for corner in corners:
		bounds = bounds.expand(corner)
	var polygon_area = 0.0
	for i in corners.size():
		polygon_area += corners[i].cross(corners[(i + 1) % corners.size()])
	if abs(polygon_area) / 2.0 >= bounds.get_area() * 0.85:
		return bounds

	# Cells of an n x n grid that lie inside, then the largest box of them
	var n = 12
	var cell = bounds.size / n
	var inside = []
	for y in n:
		var row = []
		for x in n:
			row.append(Geometry2D.is_point_in_polygon(bounds.position + cell * Vector2(x + 0.5, y + 0.5), corners))
		inside.append(row)
	var best = Rect2(bounds.get_center(), Vector2.ZERO)
	for y0 in n:
		for x0 in n:
			if not inside[y0][x0]:
				continue
			var x_end = n
			for y1 in range(y0, n):
				var x1 = x0
				while x1 < x_end and inside[y1][x1]:
					x1 += 1
				x_end = x1
				if x_end == x0:
					break
				var box = Rect2(bounds.position + cell * Vector2(x0, y0), cell * Vector2(x_end - x0, y1 - y0 + 1))
				# Wide boxes first: names are wider than tall
				if box.size.x * min(box.size.y, 0.02) > best.size.x * min(best.size.y, 0.02):
					best = box
	return best

static func _polygon_mesh(corners: PackedVector2Array) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.BACK)
	if Geometry2D.is_polygon_clockwise(corners):
		corners = corners.duplicate()
		corners.reverse()
	for i in Geometry2D.triangulate_polygon(corners):
		st.add_vertex(Vector3(corners[i].x, corners[i].y, 0))
	return st.commit()

## A band of [param thickness] along the room's edges, a little past each corner
## so the corners are closed.
static func _outline_mesh(corners: PackedVector2Array, thickness: float) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.BACK)
	var half = thickness / 2.0
	for i in corners.size():
		var a = corners[i]
		var b = corners[(i + 1) % corners.size()]
		if a.distance_to(b) < 0.0001:
			continue
		var along = (b - a).normalized()
		var across = Vector2(-along.y, along.x) * half
		a -= along * half
		b += along * half
		var quad = [a - across, b - across, b + across, a + across]
		for k in [0, 1, 2, 0, 2, 3]:
			st.add_vertex(Vector3(quad[k].x, quad[k].y, 0))
	return st.commit()
