extends Node3D
## The house's live state in the dollhouse (Map View), at the entities' places in
## the rooms:
## - lights are a dot in their colour while on (a dim one when off), and light up the
##   rooms around them: dollhouse.gdshader tints the floors and walls (light_data)
## - door and window sensors show whether they are open
## - temperature sensors show their reading
##
## Built from Store.house's entities; watches their states in Home Assistant.
## Clicking a light toggles it.

const UI = preload ("res://content/entities/entity_ui.gd")
const IconFont = preload ("res://assets/icons/icons.tres")

## Size of a light's dot, meters in the house
const LIGHT_SIZE = 0.16
## Radius of the click target around a light, in meters of the room (not the house):
## easy to hit at every zoom
const CLICK_RADIUS = 0.012
const OFF_COLOR = Color(0.42, 0.43, 0.47)
const WARM_WHITE = Color(1.0, 0.83, 0.58)
const OPEN_COLOR = Color(1.0, 0.62, 0.22)
const CLOSED_COLOR = Color(0.55, 0.84, 0.62)
## binary_sensor device classes shown as doors / windows
const OPENING_CLASSES = ["door", "window", "garage_door", "opening"]
## Labels show from this scale on (panel meters per meter): zoomed into the rooms
const LABEL_MIN_SCALE = 0.012

## entity id -> {kind: "light" | "opening" | "temperature", node: Node3D, shown: bool}
var _markers := {}
## light entity id -> Color (alpha: brightness 0..1) of the lights that are on
var _lit := {}

## Emitted when a light turns on or off or changes colour; see light_data.
signal lights_changed()

## The lights that are on: [positions (Vector3, in the house), colours (Color, alpha:
## brightness)].
func light_data() -> Array:
	var positions = []
	var colors = []
	for id in _lit:
		positions.append(_markers[id].node.position)
		colors.append(_lit[id])
	return [positions, colors]

func _notification(what):
	if what == NOTIFICATION_PREDELETE and is_instance_valid(HomeApi):
		HomeApi.unwatch_owner(self)
	# Hidden (the Map View closed): the click targets are top level, they'd stay behind.
	if what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree():
		for marker in _markers.values():
			if marker.has("body"):
				marker.body.collision_layer = 0

## Builds the markers for [param entities] (Store.house's), placed with
## [param to_house] (world -> house coordinates), no higher than [param max_height]:
## the dollhouse's cut-away walls.
func build(entities: Array, to_house: Transform3D, max_height: float):
	if is_instance_valid(HomeApi):
		HomeApi.unwatch_owner(self)
	for child in get_children():
		child.queue_free()
	_markers = {}
	_lit = {}
	lights_changed.emit()

	for entity in entities:
		var id = str(entity.id)
		var kind = {"light": "light", "binary_sensor": "opening", "sensor": "temperature"}.get(id.get_slice(".", 0))
		if kind == null or entity.get("position") == null:
			continue
		var position_in_house: Vector3 = to_house * Vector3(entity.position)
		position_in_house.y = min(position_in_house.y, max_height)
		var node = _create_light() if kind == "light" else _create_label(kind == "opening")
		node.position = position_in_house
		node.visible = false # until its state says what to show
		add_child(node)
		_markers[id] = {"kind": kind, "node": node, "shown": false}
		if kind == "light":
			_markers[id].body = _create_click_target(node)
		_watch(id)

func _watch(id: String):
	if not HomeApi.has_connected():
		await HomeApi.on_connect
	var state = await HomeApi.get_state(id)
	if not _markers.has(id):
		return # rebuilt meanwhile
	_apply(id, state)
	HomeApi.watch_state(id, func(new_state): _apply(id, new_state))

## Shows the markers at a map's zoom, as dollhouse.gd's set_view: only once the walls
## have grown, labels only zoomed into the rooms, nothing off the map's disc.
func set_view(walls: float, model_scale: float, disc, on_disc: Callable):
	visible = walls > 0.5
	if not visible:
		for marker in _markers.values():
			if marker.has("body"):
				marker.body.collision_layer = 0
		return
	var labels = model_scale >= LABEL_MIN_SCALE
	for marker in _markers.values():
		var node: Node3D = marker.node
		node.visible = marker.shown and (labels or marker.kind == "light") and on_disc.call(node.global_position, disc)
		if marker.has("body"):
			_place_click_target(marker.body, node)

## Clicking a light toggles it (events bubble up from its click target).
func _on_click(event: EventPointer):
	for id in _markers:
		var marker = _markers[id]
		if marker.get("body") == event.target:
			HomeApi.set_state(id, "off" if _lit.has(id) else "on")
			return

func _apply(id: String, state_info):
	var marker = _markers.get(id)
	if marker == null or state_info == null:
		return
	var state = str(state_info.get("state", ""))
	var attributes = UI.attributes_of(state_info)
	var node: Node3D = marker.node
	marker.shown = not UI.is_unavailable(state)

	match marker.kind:
		"light":
			var on = state == "on"
			var color = WARM_WHITE
			var rgb = attributes.get("rgb_color")
			if rgb is Array and rgb.size() >= 3:
				color = Color8(int(rgb[0]), int(rgb[1]), int(rgb[2]))
			var brightness = float(attributes.get("brightness", 255)) / 255.0 if on else 0.0
			node.get_node("Dot").material_override.albedo_color = color if on else OFF_COLOR
			if on and marker.shown:
				_lit[id] = Color(color, brightness)
			else:
				_lit.erase(id)
			lights_changed.emit()
		"opening":
			var device_class = str(attributes.get("device_class", ""))
			if not OPENING_CLASSES.has(device_class):
				marker.shown = false
			var open = state == "on"
			var label: Label3D = node
			match device_class:
				"window":
					label.text = "window"
				"garage_door":
					label.text = "garage"
				_:
					label.text = "door_open" if open else "door_front"
			label.modulate = OPEN_COLOR if open else CLOSED_COLOR
		"temperature":
			var unit = str(attributes.get("unit_of_measurement", ""))
			if attributes.get("device_class") != "temperature" and not unit in ["°C", "°F"]:
				marker.shown = false
			var label: Label3D = node
			label.text = ("%.1f°" % float(state)) if state.is_valid_float() else state

func _create_light() -> Node3D:
	var node = Node3D.new()

	var dot = MeshInstance3D.new()
	dot.name = "Dot"
	var sphere = SphereMesh.new()
	sphere.radius = LIGHT_SIZE / 2.0
	sphere.height = LIGHT_SIZE
	sphere.radial_segments = 12
	sphere.rings = 6
	dot.mesh = sphere
	var dot_material = StandardMaterial3D.new()
	dot_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dot.material_override = dot_material
	node.add_child(dot)

	return node

## A sphere the pointer can hit, around a light. Outside the miniature's scaling
## (top_level): physics doesn't handle scaled shapes well, and it should stay the same
## size in the room at every zoom anyway.
func _create_click_target(light: Node3D) -> StaticBody3D:
	var body = StaticBody3D.new()
	body.top_level = true
	body.collision_mask = 0
	body.collision_layer = 0
	var shape = CollisionShape3D.new()
	shape.shape = SphereShape3D.new()
	shape.shape.radius = CLICK_RADIUS
	body.add_child(shape)
	light.add_child(body)
	return body

func _place_click_target(body: StaticBody3D, light: Node3D):
	body.collision_layer = 1 if light.is_visible_in_tree() else 0
	if light.is_inside_tree():
		body.global_transform = Transform3D(Basis.IDENTITY, light.global_position)

## A label facing the viewer at the same size on screen at every zoom; an icon for
## doors and windows.
func _create_label(icon: bool) -> Label3D:
	var label = Label3D.new()
	label.font_size = 36 if icon else 24
	if icon:
		label.font = IconFont
	label.outline_size = 8
	label.outline_modulate = Color(0, 0, 0, 0.6)
	label.pixel_size = 0.001
	label.fixed_size = true
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.render_priority = 20
	label.outline_render_priority = 19
	# A little down on screen, clear of the room names above (dollhouse.gd)
	label.offset = Vector2(0, -14)
	return label
