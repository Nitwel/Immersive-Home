extends Node3D
## The rooms as a dollhouse, for the Map View: a floor in a soft colour per room,
## walls with a thickness, cut off at WALL_HEIGHT so you look into the rooms, with a
## dark cap that draws the floor plan from above, gaps where the doors are, a soft
## shadow along the walls on the floor, and the room names.
##
## Built in the house's coordinates (meters, floor at y = 0) from Store.house; the
## miniature scales and places it. The walls can grow out of the floor
## (set_view's walls), as the map's buildings sink into their outlines.

const DollhouseShader = preload ("./dollhouse.gdshader")
const ShadowShader = preload ("./dollhouse_shadow.gdshader")
const DollhouseEntities = preload ("./dollhouse_entities.gd")

## Cut-away height of the walls, meters
const WALL_HEIGHT = 1.1
const WALL_THICKNESS = 0.1
const WALL_COLOR = Color(0.95, 0.94, 0.92)
const CAP_COLOR = Color(0.19, 0.2, 0.23)
## Floor through the doors
const DOOR_COLOR = Color(0.85, 0.84, 0.82)
## The floor's shadow along the walls: width (m) and darkness at the wall
const SHADOW_WIDTH = 0.35
const SHADOW_ALPHA = 0.32
## Door ends this close (m) to a wall belong to it
const DOOR_SNAP = 0.2
## Room names show from this scale on (panel meters per meter): zoomed into the rooms
const LABEL_MIN_SCALE = 0.012

var _floors := MeshInstance3D.new()
var _wall_root := Node3D.new()
var _walls := MeshInstance3D.new()
var _shadows := MeshInstance3D.new()
var _labels := Node3D.new()
## Lights, doors / windows and temperatures, live
var entities := DollhouseEntities.new()
var _material := ShaderMaterial.new()
var _shadow_material := ShaderMaterial.new()

func _init():
	_material.shader = DollhouseShader
	_shadow_material.shader = ShadowShader
	_shadow_material.render_priority = 1
	_floors.material_override = _material
	_walls.material_override = _material
	_shadows.material_override = _shadow_material
	# Just above the floor
	_shadows.position.y = 0.015
	add_child(_floors)
	add_child(_shadows)
	_wall_root.add_child(_walls)
	add_child(_wall_root)
	add_child(_labels)
	add_child(entities)
	entities.lights_changed.connect(_update_lights)

## Builds the dollhouse from Store.house's rooms, doors and entities;
## [param to_house] turns the entities' (world) positions into the house's.
func build(rooms: Array, doors: Array, entity_list: Array = [], to_house := Transform3D.IDENTITY):
	var floors = _surface()
	var walls = _surface()
	var shadows = SurfaceTool.new()
	shadows.begin(Mesh.PRIMITIVE_TRIANGLES)
	for label in _labels.get_children():
		label.queue_free()

	for index in rooms.size():
		var room = rooms[index]
		var corners = PackedVector2Array()
		for corner in room.corners:
			var point = Vector2(corner.x, corner.y)
			if corners.is_empty() or corners[-1].distance_to(point) > 0.01:
				corners.append(point)
		if corners.size() > 1 and corners[0].distance_to(corners[-1]) <= 0.01:
			corners.remove_at(corners.size() - 1)
		if corners.size() < 3:
			continue
		if Geometry2D.is_polygon_clockwise(corners):
			corners.reverse()

		# Floor
		var floor_indices = Geometry2D.triangulate_polygon(corners)
		floors.set_color(_room_color(str(room.name)))
		floors.set_normal(Vector3.UP)
		floors.set_uv2(Vector2(0, 1)) # no edge lines; a floor (heat map)
		for i in floor_indices:
			floors.add_vertex(Vector3(corners[i].x, 0, corners[i].y))

		# Walls, a little higher per room: where two rooms' walls overlap, one cap wins
		var height = min(float(room.get("height", 2.5)), WALL_HEIGHT) + index * 0.002
		var count = corners.size()
		var outwards = []
		for i in count:
			var along = (corners[(i + 1) % count] - corners[i]).normalized()
			var outward = Vector2(along.y, -along.x)
			if Geometry2D.is_point_in_polygon((corners[i] + corners[(i + 1) % count]) / 2.0 + outward * 0.01, corners):
				outward = -outward
			outwards.append(outward)
		# Outer corner of the walls at each room corner: where the outsides of the two
		# walls meet (mitred, like a picture frame), so they neither overlap nor gap.
		var miters = []
		for i in count:
			miters.append(_miter(corners[i], outwards[(i - 1 + count) % count], outwards[i]))

		for i in count:
			var a = corners[i]
			var b = corners[(i + 1) % count]
			var length = a.distance_to(b)
			var along = (b - a) / length
			var outward: Vector2 = outwards[i]
			for segment in _wall_segments(room.name, a, along, length, doors):
				var at_start = segment.x <= 0.0
				var at_end = segment.y >= length
				var p = a + along * segment.x
				var q = a + along * segment.y
				# At a door the wall ends square; at a room corner it ends at the mitre.
				var outer_p = miters[i] if at_start else p + outward * WALL_THICKNESS
				var outer_q = miters[(i + 1) % count] if at_end else q + outward * WALL_THICKNESS
				_add_wall(walls, p, q, outer_p, outer_q, height, not at_start, not at_end)
				_add_shadow(shadows, p, q, -outward)

		_add_label(str(room.name), corners)

	# Floor through each door, between the two rooms' walls
	floors.set_color(DOOR_COLOR)
	for door in doors:
		var points = [door.room1_position1, door.room1_position2, door.room2_position2, door.room2_position1]
		for k in [0, 1, 2, 0, 2, 3]:
			floors.add_vertex(Vector3(points[k].x, 0, points[k].z))

	entities.build(entity_list, to_house, WALL_HEIGHT)

	_floors.mesh = floors.commit()
	_walls.mesh = walls.commit()
	_shadows.mesh = shadows.commit()

## Shows the dollhouse at a map's zoom: [param walls] 0..1 how far the walls have
## grown out of the floor, [param model_scale] panel meters per meter (room names
## show when zoomed in), [param disc] the map's [centre, up, radius] in world space
## to cut it off at (null: not cut).
func set_view(walls: float, model_scale: float, disc):
	_wall_root.visible = walls > 0.01
	_wall_root.scale.y = max(walls, 0.001)
	_shadow_material.set_shader_parameter("opacity", walls)
	for material in [_material, _shadow_material]:
		material.set_shader_parameter("clip_to_disc", disc != null)
		if disc != null:
			material.set_shader_parameter("disc_center", disc[0])
			material.set_shader_parameter("disc_normal", disc[1])
			material.set_shader_parameter("disc_radius", disc[2])
	entities.set_view(walls, model_scale, disc, _on_disc)
	var show_labels = walls > 0.5 and model_scale >= LABEL_MIN_SCALE
	for label in _labels.get_children():
		label.visible = show_labels and _on_disc(label.global_position, disc)

## Passes the lights that are on to the shader, which lights up the rooms around them.
func _update_lights():
	var data = entities.light_data()
	var positions = []
	var colors = []
	for i in mini(data[0].size(), 32):
		var p: Vector3 = data[0][i]
		var c: Color = data[1][i]
		positions.append(Vector4(p.x, p.y, p.z, 0.0))
		colors.append(Vector4(c.r, c.g, c.b, c.a))
	_material.set_shader_parameter("light_positions", positions)
	_material.set_shader_parameter("light_colors", colors)
	_material.set_shader_parameter("light_count", positions.size())

## Heat map on the floors: [param gradient] colours the readings, null turns it off.
func set_heat(gradient):
	_material.set_shader_parameter("heat", gradient != null)
	if gradient != null:
		_material.set_shader_parameter("color_gradient", gradient)

## How strongly the heat map colours the floors, 0..1.
func set_heat_strength(strength: float):
	_material.set_shader_parameter("heat_strength", strength)

## The readings for the heat map: Vector4(x, y, z in the house, value 0..1) each.
func set_heat_data(data: Array):
	_material.set_shader_parameter("data", data)
	_material.set_shader_parameter("data_size", data.size())

static func _on_disc(point: Vector3, disc) -> bool:
	if disc == null:
		return true
	var offset: Vector3 = point - disc[0]
	var normal: Vector3 = disc[1]
	return (offset - offset.dot(normal) * normal).length() <= disc[2]

static func _surface() -> SurfaceTool:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	return st

## A soft colour per room, the same every time for the same name.
static func _room_color(room_name: String) -> Color:
	var hue = fposmod(float(hash(room_name) % 1000) * 0.618034, 1.0)
	return Color.from_hsv(hue, 0.2, 0.93)

## The parts of a wall (as Vector2(from, to) along it, meters) between its doors.
static func _wall_segments(room_name, a: Vector2, along: Vector2, length: float, doors: Array) -> Array:
	var gaps = []
	for door in doors:
		for side in [[door.room1, door.room1_position1, door.room1_position2], [door.room2, door.room2_position1, door.room2_position2]]:
			if side[0] != room_name:
				continue
			var p1 = Vector2(side[1].x, side[1].z)
			var p2 = Vector2(side[2].x, side[2].z)
			if _distance_to_line(p1, a, along) > DOOR_SNAP or _distance_to_line(p2, a, along) > DOOR_SNAP:
				continue
			var t1 = clamp((p1 - a).dot(along), 0.0, length)
			var t2 = clamp((p2 - a).dot(along), 0.0, length)
			if abs(t2 - t1) > 0.05:
				gaps.append(Vector2(min(t1, t2), max(t1, t2)))
	# Vector2s sort by x (the start) first. No sort_custom: a lambda in a static
	# function has no instance to run on.
	gaps.sort()

	var segments = []
	var start = 0.0
	for gap in gaps:
		if gap.x > start + 0.01:
			segments.append(Vector2(start, gap.x))
		start = max(start, gap.y)
	if start < length - 0.01:
		segments.append(Vector2(start, length))
	return segments

static func _distance_to_line(p: Vector2, a: Vector2, along: Vector2) -> float:
	var offset = p - a
	return (offset - along * offset.dot(along)).length()

## Where the outsides of two walls meeting at [param corner] cross, WALL_THICKNESS
## out from their insides ([param before] / [param after]: their outward normals).
static func _miter(corner: Vector2, before: Vector2, after: Vector2) -> Vector2:
	var direction = before + after
	if direction.length() < 0.001: # the wall turns right back: no corner to close
		return corner + after * WALL_THICKNESS
	direction = direction.normalized()
	# Very sharp corners would throw the point far out; cut them off instead.
	return corner + direction * WALL_THICKNESS / max(direction.dot(after), 0.3)

## A wall from [param p] to [param q] (its inner side, on the room's floor plan) to
## [param outer_p] / [param outer_q] (its outer side), [param height] high. End
## faces only where it stops on its own ([param end_p] / [param end_q]: at doors);
## at corners the next wall carries on.
static func _add_wall(st: SurfaceTool, p: Vector2, q: Vector2, outer_p: Vector2, outer_q: Vector2, height: float, end_p: bool, end_q: bool):
	var up = Vector3(0, height, 0)
	var p0 = Vector3(p.x, 0, p.y)
	var q0 = Vector3(q.x, 0, q.y)
	var pp = Vector3(outer_p.x, 0, outer_p.y)
	var qq = Vector3(outer_q.x, 0, outer_q.y)
	var along3 = (q0 - p0).normalized()
	var outward3 = Vector3(along3.z, 0, -along3.x)
	if outward3.dot(pp + qq - p0 - q0) < 0.0:
		outward3 = -outward3
	_quad(st, [p0, q0, q0 + up, p0 + up], -outward3, WALL_COLOR) # inside
	_quad(st, [qq, pp, pp + up, qq + up], outward3, WALL_COLOR) # outside
	# The dark cap draws the floor plan; no edge lines (they would mark every mitre).
	_quad(st, [p0 + up, q0 + up, qq + up, pp + up], Vector3.UP, CAP_COLOR, false)
	if end_p:
		_quad(st, [pp, p0, p0 + up, pp + up], -along3, WALL_COLOR)
	if end_q:
		_quad(st, [q0, qq, qq + up, q0 + up], along3, WALL_COLOR)

## A face with UVs 0..1 across it, so the shader draws its edges (unless
## [param edges] is off).
static func _quad(st: SurfaceTool, corners: Array, normal: Vector3, color: Color, edges := true):
	var uvs = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
	st.set_normal(normal)
	st.set_color(color)
	st.set_uv2(Vector2(1 if edges else 0, 0))
	for k in [0, 1, 2, 0, 2, 3]:
		st.set_uv(uvs[k])
		st.add_vertex(corners[k])

## The floor's shadow along a wall from [param p] to [param q], fading [param inward].
static func _add_shadow(st: SurfaceTool, p: Vector2, q: Vector2, inward: Vector2):
	var dark = Color(0, 0, 0, SHADOW_ALPHA)
	var clear = Color(0, 0, 0, 0)
	var p0 = Vector3(p.x, 0, p.y)
	var q0 = Vector3(q.x, 0, q.y)
	var offset = Vector3(inward.x, 0, inward.y) * SHADOW_WIDTH
	var corners = [p0, q0, q0 + offset, p0 + offset]
	var colors = [dark, dark, clear, clear]
	for k in [0, 1, 2, 0, 2, 3]:
		st.set_color(colors[k])
		st.add_vertex(corners[k])

func _add_label(text: String, corners: PackedVector2Array):
	var center = Vector2.ZERO
	for corner in corners:
		center += corner
	center /= corners.size()

	var label = Label3D.new()
	label.text = text
	label.font_size = 30
	label.outline_size = 10
	label.outline_modulate = Color(0, 0, 0, 0.55)
	label.pixel_size = 0.0011
	# Same size on screen at every zoom, facing the viewer, over the walls
	label.fixed_size = true
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.render_priority = 20
	label.outline_render_priority = 19
	label.position = Vector3(center.x, WALL_HEIGHT + 0.2, center.y)
	# A little up on screen: readings (dollhouse_entities.gd) sit a little down
	label.offset = Vector2(0, 14)
	label.visible = false
	_labels.add_child(label)
