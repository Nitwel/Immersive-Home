extends StaticBody3D
## Floating map of all people and device trackers, like Home Assistant's Map panel:
## their current positions, the zones, and the paths they took over the selected
## time range. Toggled from the View menu ("Map View"). The round map lies flat in
## front of the user like the miniature; the controls and the entity list stand
## upright on its far side and follow round as the user walks around it. Movable /
## resizable. Can switch between the flat and the 3D map.
##
## The miniature house (content/system/miniature) stands on the map at the home
## zone, to the map's scale; zooming in past the map's own levels leaves only the
## rooms and the building outlines around them. Its compass heading is set with the rotate buttons
## (stored as the house's map_heading).

const UI = preload ("res://content/entities/entity_ui.gd")
const MapView = preload ("res://content/entities/person/map_view.gd")
const Map3D = preload ("res://content/entities/person/map_3d.gd")
const Tiles = preload ("res://content/entities/person/map_tiles.gd")
const MovableScript = preload ("res://content/functions/movable.gd")
const MapPan = preload ("res://content/entities/person/map_pan.gd")

const PAD = 0.015
## The round map (its diameter), and the plate it lies on
const MAP_SIZE = Vector2(0.56, 0.56)
const PLATE = MAP_SIZE.x + 2 * PAD
## Upright panel with the header, the entity list and the status line
const PANEL_SIZE = Vector2(0.66, 0.27)
const HEADER = 0.06
const COLUMNS = 3
const ROW_GAP = 0.01
const ROW_WIDTH = (PANEL_SIZE.x - 2 * PAD - (COLUMNS - 1) * ROW_GAP) / COLUMNS
const ROW_HEIGHT = 0.042
const MAX_ROWS = 9
## The panel leans back this far, as it is looked down at.
const PANEL_LEAN = deg_to_rad(15.0)
## Space between the plate and the panel
const PANEL_GAP = 0.02
const FOCUS_ZOOM = 16
## Extra meters around the house's floor plan in which buildings of the 3D map are
## drawn as outlines, so its own building doesn't hide the miniature. The neighbours
## stay solid.
const HOUSE_MARGIN = 3.0
## Degrees the house turns per press (repeats while held) of a rotate button.
const HEADING_STEP = 1.0
## Zoom of the aerial view (house button row): the neighbourhood around home
const AERIAL_ZOOM = 17.0
## Seconds the rooms / aerial buttons take to zoom there
const FLY_TIME = 0.8
const MAX_PATH_POINTS = 400
## Reload the history this often while the map is shown.
const HISTORY_REFRESH = 600.0

const RANGES = {"1": "1 hour", "6": "6 hours", "24": "24 hours", "72": "3 days", "168": "7 days"}
## Path / marker colours, one per tracked entity
const COLORS = [Color8(51, 136, 255), Color8(255, 152, 0), Color8(76, 175, 80), Color8(156, 39, 176),
	Color8(0, 150, 136), Color8(233, 30, 99), Color8(121, 85, 72), Color8(96, 125, 139)]
const HOME_COLOR = Color8(255, 152, 0)
const ZONE_COLOR = Color8(70, 130, 200)

signal on_close()

var hours = R.state("24")
var use_3d = R.state(false)

var map: MapView
var map_3d: Map3D
var _rows := Node3D.new()
var _status_label: Label3D
var _history_timer := Timer.new()

## Tracked entity ids (people, then trackers that aren't a person's source)
var _tracked: Array = []
var _zones: Array = []
var _states := {}
## entity id -> Array of Vector2(lat, lon), oldest first
var _paths := {}
var _focused = null
var _zoom_offset := 0.0
var _base_view = null ## [center, zoom] from fitting everything or the focused entity
## Map centre the user dragged to; null while showing _base_view's centre.
var _pan_center = null
var _pan := MapPan.new()
var _loading = false
## Header buttons for the house on the map; only in the tree while it is shown.
var _house_buttons := Node3D.new()
## Point of the house (world / miniature model coordinates) that stands on the home
## zone: the middle of its floor plan. null until worked out.
var _house_anchor = null
## Meters from the anchor to the house's farthest corner
var _house_radius := 0.0
## Lying flat, +Z up and +Y north: the map and the glass it lies on
var _plate := Node3D.new()
## Stands at the edge of the plate facing away from the user (see _update_panel).
## Its own body, so pressing it doesn't pan the map; grabbing it still moves all.
var _panel := StaticBody3D.new()
var _panel_content := Node3D.new()
## Direction the panel faces, around the up axis; null until placed
var _panel_yaw = null

func _ready():
	_build()
	R.effect(func(_arg):
		use_3d.value
		_update_map()
	)

	add_child(_pan)
	_pan.changed.connect(func(new_center, new_zoom):
		_pan_center = new_center
		if _base_view != null:
			_zoom_offset = new_zoom - _base_view[1]
		_update_map()
	)

	_history_timer.wait_time = HISTORY_REFRESH
	# Refreshing keeps the view; only a new range or reload fits the map to the paths.
	_history_timer.timeout.connect(_load_history.bind(false))
	add_child(_history_timer)
	_history_timer.start()

	if HomeApi.has_connected() == false:
		await HomeApi.on_connect
	await reload()

func _notification(what):
	# The state watchers are lambdas on this node; drop them before it is freed.
	if what == NOTIFICATION_PREDELETE and is_instance_valid(HomeApi):
		HomeApi.unwatch_owner(self)
	# Hidden (taken out of the tree) or freed: the miniature goes back to its own spot.
	if what == NOTIFICATION_EXIT_TREE and is_instance_valid(App.miniature):
		App.miniature.leave_map()
		_house_anchor = null

## Lays the map flat in front of [param camera], like the miniature: at half eye
## height, north away from the viewer.
func open_in_front_of(camera: Node3D):
	var forward = -camera.global_transform.basis.z
	forward.y = 0
	forward = forward.normalized() if forward.length() > 0.01 else Vector3.FORWARD
	var target = camera.global_position + forward * 0.6
	target.y = camera.global_position.y * 0.5
	# looking_at points -Z away from the viewer.
	global_transform = Transform3D(Basis.looking_at(forward, Vector3.UP), target)
	_panel_yaw = null # straight to its spot, no swinging round
	_update_panel(0.0)

func _process(delta):
	_update_panel(delta)
	_update_house()

## Keeps the panel standing just behind the map, as seen from the user, facing them.
## It swings round smoothly as they walk around the map.
func _update_panel(delta: float):
	var camera = get_viewport().get_camera_3d() if is_inside_tree() else null
	if camera == null:
		return
	var eye = to_local(camera.global_position)
	var toward = Vector2(eye.x, eye.z)
	if toward.length() > 0.05: # right above the map, keep it where it is
		# Turning +Z (the panel's front) by yaw around Y points it at (sin, cos).
		var yaw = atan2(toward.x, toward.y)
		_panel_yaw = yaw if _panel_yaw == null else lerp_angle(_panel_yaw, yaw, 1.0 - exp(-delta * 5.0))
	if _panel_yaw == null:
		_panel_yaw = 0.0
	var away = -Vector2(sin(_panel_yaw), cos(_panel_yaw))
	var distance = PLATE / 2.0 + PANEL_GAP
	_panel.transform = Transform3D(Basis(Vector3.UP, _panel_yaw) * Basis(Vector3.RIGHT, -PANEL_LEAN),
		Vector3(away.x * distance, 0.005, away.y * distance))

## Stands the miniature on the map at the home zone (once there are rooms).
func _update_house():
	var miniature = App.miniature
	if miniature == null: # not in the main scene (galleries)
		return
	var home = _location(_states.get("zone.home"))
	var active = home != null and map != null and Store.house.state.rooms.size() > 0
	if active != (_house_buttons.get_parent() != null):
		if active:
			_panel_content.add_child(_house_buttons)
		else:
			_panel_content.remove_child(_house_buttons)
		# With the house shown, zoom on past the map into the rooms.
		for view in [map, map_3d]:
			view.max_zoom = Tiles.ROOMS_MAX_ZOOM if active else float(Tiles.MAX_ZOOM)
		_update_map()
	if not active:
		miniature.leave_map()
		map_3d.clear_ghost()
		_house_anchor = null
		return

	if _house_anchor == null:
		var aabb: AABB = App.house.get_rooms_aabb()
		_house_anchor = Vector3(aabb.get_center().x, aabb.position.y, aabb.get_center().z)
		_house_radius = Vector2(aabb.size.x, aabb.size.z).length() / 2.0

	# The map's own houses would hide the miniature: outlines only around it.
	if use_3d.value:
		map_3d.set_ghost(home.x, home.y, _house_radius + HOUSE_MARGIN)
	else:
		map_3d.clear_ghost()

	var view = map_3d if use_3d.value else map
	var frame: Transform3D = view.surface_transform(home.x, home.y)
	# The map may have been resized; the body stays unscaled, the model takes it.
	var model_scale = view.panel_per_meter(home.x) * frame.basis.get_scale().x
	frame = frame.orthonormalized()
	# Just above the surface: the terrain between its grid points can be higher.
	frame.origin += frame.basis.y * 0.0008
	# A compass bearing turns clockwise seen from above; Basis turns the other way.
	var turn = Basis(Vector3.UP, -deg_to_rad(float(Store.house.state.map_heading)))
	var body_transform = frame * Transform3D(turn, turn * (-_house_anchor * model_scale))
	# Cut off at the map's rim (zoomed in, the house is larger than the map).
	var up = global_transform.basis.y
	var disc = [global_position + up.normalized() * 0.001, up.normalized(), MAP_SIZE.x / 2.0 * up.length()]
	# The walls grow out of the floor as the map fades into the rooms (and the map's
	# buildings sink into their outlines).
	var walls = 1.0 - Tiles.map_opacity(view.get_fractional_zoom())
	miniature.place_on_map(body_transform, model_scale, view.is_visible_in_tree(), disc, walls)

func _turn_house(degrees: float):
	Store.house.state.map_heading = fposmod(float(Store.house.state.map_heading) + degrees, 360.0)

var _fly_tween: Tween

## Flies the map to the home zone: into the rooms (the house filling most of the
## map, past the map's own zoom levels) or out to the aerial view around it. The
## zoom is animated, so the map fades into the rooms or back.
func _fly_home(into_rooms: bool):
	var home = _location(_states.get("zone.home"))
	if home == null:
		return
	var target_zoom = AERIAL_ZOOM
	if into_rooms:
		target_zoom = float(Tiles.MAX_ZOOM)
		if _house_anchor != null and _house_radius > 0.0:
			# Panel m per ground m is 2^zoom / (156543 cos(lat) * PIXELS_PER_METER); make
			# the house's diameter 80 % of the map's.
			var wanted = 0.8 * MAP_SIZE.x / (2.0 * _house_radius)
			target_zoom = log(wanted * 156543.03392 * cos(deg_to_rad(home.x)) * MapView.PIXELS_PER_METER) / log(2.0)
	target_zoom = clamp(target_zoom, Tiles.MIN_ZOOM, map.max_zoom)

	var view = map_3d if use_3d.value else map
	var start_center = view.center.duplicate()
	var start_zoom = view.get_fractional_zoom()
	_focused = null
	_update_rows()
	_stop_flying()
	_fly_tween = create_tween()
	_fly_tween.tween_method(func(t: float):
		# Ease the zoom; move the centre along with it, done halfway on the way in.
		var zoom = lerp(start_zoom, target_zoom, t)
		var move = clamp(t * 2.0, 0.0, 1.0) if target_zoom > start_zoom else t
		_base_view = [[lerp(start_center[0], float(home.x), move), lerp(start_center[1], float(home.y), move)], zoom]
		_zoom_offset = 0.0
		_pan_center = null
		_update_map()
	, 0.0, 1.0, FLY_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _stop_flying():
	if _fly_tween != null and _fly_tween.is_valid():
		_fly_tween.kill()

## Pressing the map (not a button or row) starts dragging it; a second hand zooms.
func _on_press_down(event: EventPointer):
	if event.target in [self, map.body, map_3d.body]:
		_stop_flying() # the hand takes over
		_pan.start(event, map_3d if use_3d.value else map)

func _on_press_up(event: EventPointer):
	_pan.stop(event)

# ---------------------------------------------------------------------------
# Layout
# ---------------------------------------------------------------------------

func _build():
	# The plate the map lies on; grabbing it moves everything.
	var collision = CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	collision.shape = CylinderShape3D.new()
	collision.shape.radius = PLATE / 2.0
	collision.shape.height = 0.02
	collision.position = Vector3(0, -0.01, 0)
	add_child(collision)

	var movable = MovableScript.new()
	movable.resizable = true
	add_child(movable)

	_plate.rotation.x = -PI / 2.0
	add_child(_plate)
	UI.glass(_plate, Vector2(PLATE, PLATE)).corner_radius = PLATE / 2.0 # a disc

	map = MapView.new()
	map.size = MAP_SIZE
	map.circular = true
	map.building_outlines = true
	map.position = Vector3(0, 0, 0.001)
	_plate.add_child(map)

	map_3d = Map3D.new()
	map_3d.size = MAP_SIZE
	map_3d.circular = true
	map_3d.building_outlines = true
	# The plate already lies flat, so the diorama lies in its plane instead of being
	# tilted towards the viewer like on the person card.
	map_3d.tilt = PI / 2.0
	map_3d.position = Vector3(0, MAP_SIZE.y / 2.0, 0.002)
	map_3d.visible = false
	_plate.add_child(map_3d)

	# The upright panel; its origin is its bottom edge, which it leans back around.
	add_child(_panel)
	var panel_collision = CollisionShape3D.new()
	panel_collision.shape = BoxShape3D.new()
	panel_collision.shape.size = Vector3(PANEL_SIZE.x, PANEL_SIZE.y, 0.02)
	panel_collision.position = Vector3(0, PANEL_SIZE.y / 2.0, -0.01)
	_panel.add_child(panel_collision)
	_panel_content.position.y = PANEL_SIZE.y / 2.0
	_panel.add_child(_panel_content)
	_build_panel(_panel_content)

func _build_panel(panel: Node3D):
	UI.glass(panel, PANEL_SIZE)

	var top = PANEL_SIZE.y / 2.0 - HEADER / 2.0
	var left = -PANEL_SIZE.x / 2.0 + PAD
	UI.label(panel, "map", 26, Vector3(left + 0.012, top, 0), HORIZONTAL_ALIGNMENT_CENTER, true)
	UI.label(panel, "Map", 26, Vector3(left + 0.03, top, 0))

	# Header controls, right to left
	var x = PANEL_SIZE.x / 2.0 - PAD - 0.0175
	var close = UI.icon_button(panel, "close", Vector3(x, top, 0), 0.035)
	close.on_button_up.connect(func(): on_close.emit())
	x -= 0.05
	var fit = UI.icon_button(panel, "fit_screen", Vector3(x, top, 0), 0.035)
	fit.on_button_up.connect(func(): _focus(null))
	x -= 0.043
	var zoom_in = UI.icon_button(panel, "add", Vector3(x, top, 0), 0.035, true)
	zoom_in.on_button_down.connect(func(): _change_zoom(1))
	x -= 0.043
	var zoom_out = UI.icon_button(panel, "remove", Vector3(x, top, 0), 0.035, true)
	zoom_out.on_button_down.connect(func(): _change_zoom(-1))
	x -= 0.05
	var mode: Button3D = UI.icon_button(panel, "view_in_ar", Vector3(x, top, 0), 0.035)
	mode.toggleable = true
	R.bind(mode, "active", use_3d, mode.on_toggled)
	x -= 0.03 + 0.065
	var range_select = UI.select(panel, Vector3(x, top, 0), 0.13)
	range_select.sort_options = false
	range_select.options = RANGES
	range_select.selected = hours.value
	range_select.on_select.connect(func(value):
		if value != null and value != hours.value:
			hours.value = value
			_load_history()
	)

	# House on the map (see _update_house): bottom row, right to left
	var bottom = -PANEL_SIZE.y / 2.0 + PAD + 0.0175
	x = PANEL_SIZE.x / 2.0 - PAD - 0.0175
	var turn_right = UI.icon_button(_house_buttons, "rotate_right", Vector3(x, bottom, 0), 0.035, true)
	turn_right.on_button_down.connect(_turn_house.bind(HEADING_STEP))
	turn_right.on_button_up.connect(func(): Store.house.save_local())
	x -= 0.043
	var turn_left = UI.icon_button(_house_buttons, "rotate_left", Vector3(x, bottom, 0), 0.035, true)
	turn_left.on_button_down.connect(_turn_house.bind(-HEADING_STEP))
	turn_left.on_button_up.connect(func(): Store.house.save_local())
	x -= 0.06
	var aerial = UI.icon_button(_house_buttons, "satellite_alt", Vector3(x, bottom, 0), 0.035)
	aerial.on_button_up.connect(_fly_home.bind(false))
	x -= 0.043
	var rooms = UI.icon_button(_house_buttons, "nest_multi_room", Vector3(x, bottom, 0), 0.035)
	rooms.on_button_up.connect(_fly_home.bind(true))

	# Entity list below, in columns
	_rows.position = Vector3(left + ROW_WIDTH / 2.0, PANEL_SIZE.y / 2.0 - HEADER - ROW_HEIGHT / 2.0, 0)
	panel.add_child(_rows)
	_status_label = UI.label(panel, "Loading…", 13, Vector3(left, -PANEL_SIZE.y / 2.0 + PAD + 0.006, 0))
	_status_label.modulate = Color(1, 1, 1, 0.6)

func _build_rows():
	for child in _rows.get_children():
		_rows.remove_child(child) # right away, so the row indexes match _tracked
		child.queue_free()

	for i in mini(_tracked.size(), MAX_ROWS):
		var id = _tracked[i]
		var row = Node3D.new()
		row.position = Vector3((i % COLUMNS) * (ROW_WIDTH + ROW_GAP), -floori(i / float(COLUMNS)) * (ROW_HEIGHT + 0.006), 0)
		_rows.add_child(row)

		var button: Button3D = UI.ButtonScene.instantiate()
		button.label = "" # the scene's default is placeholder text; the row draws its own labels
		button.size = Vector3(ROW_WIDTH, ROW_HEIGHT, 0.01)
		button.toggleable = true
		row.add_child(button)
		# on_toggled also fires when _update_rows syncs the rows, so only act when the
		# button disagrees with the current focus.
		button.on_toggled.connect(func(active):
			if active and _focused != id:
				_focus(id)
			elif not active and _focused == id:
				_focus(null)
		)
		row.set_meta("button", button)

		var dot = MapView.create_marker_node()
		dot.position = Vector3(-ROW_WIDTH / 2.0 + 0.02, 0, 0.012)
		row.add_child(dot)
		row.set_meta("dot", dot)

		var name_label = UI.label(row, id, 15, Vector3(-ROW_WIDTH / 2.0 + 0.038, 0.007, 0.012))
		row.set_meta("name", name_label)
		var state_label = UI.label(row, "", 12, Vector3(-ROW_WIDTH / 2.0 + 0.038, -0.009, 0.012))
		state_label.modulate = Color(1, 1, 1, 0.7)
		row.set_meta("state", state_label)

	_update_rows()

func _update_rows():
	for i in _rows.get_child_count():
		var row = _rows.get_child(i)
		if i >= _tracked.size():
			continue
		var id = _tracked[i]
		var attributes = UI.attributes_of(_states.get(id))
		var entity_name = UI.entity_name(id, attributes)
		row.get_meta("name").text = entity_name
		row.get_meta("state").text = _state_text(str(_states.get(id, {}).get("state", "")))
		MapView.apply_marker(row.get_meta("dot"), {"text": _initials(entity_name), "color": _color(id), "diameter": 0.024})
		row.get_meta("button").active = _focused == id

# ---------------------------------------------------------------------------
# Data
# ---------------------------------------------------------------------------

## Finds the people, trackers and zones, then loads their history.
func reload():
	var people = HomeApi.get_entity_ids(["person"])
	var trackers = HomeApi.get_entity_ids(["device_tracker"])
	_zones = HomeApi.get_entity_ids(["zone"])

	for id in people + trackers + _zones:
		_states[id] = await HomeApi.get_state(id)

	# A person's position comes from one of its trackers; showing both would be a duplicate.
	var sources = people.map(func(id): return UI.attributes_of(_states[id]).get("source"))
	trackers = trackers.filter(func(id): return not sources.has(id) and _location(_states[id]) != null)
	people.sort_custom(func(a, b): return _name(a) < _name(b))
	trackers.sort_custom(func(a, b): return _name(a) < _name(b))
	_tracked = people + trackers

	for id in _tracked + _zones:
		HomeApi.watch_state(id, func(new_state): _on_state(id, new_state))

	_build_rows()
	await _load_history()

func _on_state(id: String, state_info):
	if state_info == null:
		return
	_states[id] = state_info
	# Extend the path live, as positions come in
	var location = _location(state_info)
	if location != null and _paths.has(id):
		var path: Array = _paths[id]
		if path.is_empty() or path[-1].distance_to(location) > 0.00001:
			path.append(location)
	_update_rows()
	_update_map()

func _load_history(refit := true):
	if _loading or _tracked.is_empty():
		_status_label.text = "No people or trackers" if _tracked.is_empty() else _status_label.text
		return
	_loading = true
	_status_label.text = "Loading history…"

	var start = Time.get_unix_time_from_system() - int(hours.value) * 3600
	var history = await HomeApi.get_state_history(_tracked, Time.get_datetime_string_from_unix_time(int(start)) + "Z")
	_loading = false

	_paths = {}
	for id in _tracked:
		var points = []
		for entry in history.get(id, []):
			var location = _location(entry)
			if location != null and (points.is_empty() or points[-1].distance_to(location) > 0.00001):
				points.append(location)
		var current = _location(_states.get(id))
		if current != null and (points.is_empty() or points[-1].distance_to(current) > 0.00001):
			points.append(current)
		_paths[id] = _thin(points)

	_status_label.text = "Paths: last " + RANGES.get(hours.value, hours.value + " hours")
	if refit:
		_base_view = null # fit to the new paths
		_pan_center = null
	_update_map()

# ---------------------------------------------------------------------------
# Map
# ---------------------------------------------------------------------------

func _update_map():
	if map == null:
		return

	var circles = []
	var markers = []
	for id in _zones:
		var location = _location(_states.get(id))
		if location == null:
			continue
		var attributes = UI.attributes_of(_states[id])
		var is_home = id == "zone.home"
		var color = HOME_COLOR if is_home else ZONE_COLOR
		circles.append({"lat": location.x, "lon": location.y, "radius": float(attributes.get("radius", 100)), "color": Color(color, 0.16)})
		markers.append({"lat": location.x, "lon": location.y, "text": "home" if is_home else "location_on", "icon": true, "color": color, "diameter": 0.016})

	var paths = []
	var fit_points = []
	for id in _tracked:
		var path = _paths.get(id, [])
		if path.size() > 1:
			paths.append({"points": path, "color": _color(id)})
		fit_points.append_array(path)
		var location = _location(_states.get(id))
		if location != null:
			fit_points.append(location)
			markers.append({"lat": location.x, "lon": location.y, "text": _initials(_name(id)), "color": _color(id), "diameter": 0.024})

	var home = _location(_states.get("zone.home"))
	if home != null:
		fit_points.append(home)
	if fit_points.is_empty():
		return

	if _base_view == null:
		if _focused != null and _location(_states.get(_focused)) != null:
			_base_view = [_location(_states[_focused]), FOCUS_ZOOM]
		else:
			_base_view = map.fit(fit_points, FOCUS_ZOOM)

	var in_3d = use_3d.value
	map.visible = not in_3d
	map_3d.visible = in_3d
	var view = map_3d if in_3d else map
	view.markers = markers
	view.circles = circles
	view.paths = paths
	view.center = _pan_center if _pan_center != null else _base_view[0]
	view.set_fractional_zoom(_base_view[1] + _zoom_offset)
	view.refresh()

func _focus(id):
	_stop_flying()
	_focused = id
	_zoom_offset = 0
	_base_view = null
	_pan_center = null
	_update_rows()
	_update_map()

func _change_zoom(direction: int):
	_stop_flying()
	if _base_view == null:
		return
	# Buttons step to the next whole level, also after a pinch left it in between.
	_zoom_offset = clamp(roundi(_base_view[1] + _zoom_offset) + direction, Tiles.MIN_ZOOM, map.max_zoom) - _base_view[1]
	_update_map()

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _color(id: String) -> Color:
	var index = _tracked.find(id)
	return COLORS[posmod(index, COLORS.size())]

func _name(id: String) -> String:
	return UI.entity_name(id, UI.attributes_of(_states.get(id)))

static func _location(state_info):
	var attributes = UI.attributes_of(state_info)
	if attributes.get("latitude") == null or attributes.get("longitude") == null:
		return null
	return Vector2(float(attributes.latitude), float(attributes.longitude))

static func _state_text(state: String) -> String:
	match state:
		"home": return "Home"
		"not_home": return "Away"
		"unknown", "unavailable", "": return state.capitalize()
	return state

static func _initials(text: String) -> String:
	var result = ""
	for word in text.split(" ", false).slice(0, 2):
		result += word.substr(0, 1).to_upper()
	return result

## Keeps at most MAX_PATH_POINTS evenly spread points (and always the last one).
static func _thin(points: Array) -> Array:
	if points.size() <= MAX_PATH_POINTS:
		return points
	var result = []
	var step = float(points.size() - 1) / (MAX_PATH_POINTS - 1)
	for i in MAX_PATH_POINTS:
		result.append(points[int(round(i * step))])
	return result