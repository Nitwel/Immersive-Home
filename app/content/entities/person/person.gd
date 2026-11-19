extends Entity
## person / device_tracker: who it is, where they are ("Home", "Away" or a zone
## name) and a map like Home Assistant's map card, with the home zone and the
## GPS accuracy around the position. The settings switch the map to a 3D diorama
## with terrain, buildings and trees (map_3d.gd).

const Entity = preload ("../entity.gd")
const UI = preload ("../entity_ui.gd")
const MapView = preload ("./map_view.gd")
const Map3D = preload ("./map_3d.gd")
const Tiles = preload ("./map_tiles.gd")
const MarkerShader = preload ("./marker.gdshader")
const MapPan = preload ("./map_pan.gd")

const WIDTH = 0.30
const HEIGHT = 0.28
const MAP_SIZE = Vector2(0.28, 0.19)
## Footprint of the 3D map (width x depth); tilted it fits the 2D map's area.
## Narrower than the card: its front edge comes towards the viewer and looks wider.
const MAP_3D_SIZE = Vector2(0.24, 0.19)
const AVATAR_SIZE = 0.036
const SETTINGS_SIZE = Vector2(0.18, 0.085)
## Zoom used when only the position is shown (home is too far away to fit).
const DEFAULT_ZOOM = 14
const DEFAULT_ZOOM_3D = 16
## Zoom out no further than this to fit home and the position together.
const MIN_FIT_ZOOM = 11

const ACCENT = Color(0.949, 0.353, 0.22)
const HOME_ZONE_COLOR = Color(1.0, 0.6, 0.0, 0.18)
const ACCURACY_COLOR = Color(0.35, 0.65, 1.0, 0.18)

var avatar: MeshInstance3D
var avatar_label: Label3D
var name_label: Label3D
var state_label: Label3D
var map: MapView
var map_3d: Map3D
var no_location_label: Label3D
var zoom_in: Button3D
var zoom_out: Button3D
## Back to following the position after the map was dragged
var recenter: Button3D
var settings: Node3D
var pan := MapPan.new()
## Map centre the user dragged to; null while the map follows the position.
var _pan_center = null
var picture_request := HTTPRequest.new()

## Option: show the 3D map instead of the flat one.
var use_3d_map = R.state(false)

var picture: Texture2D = null
var _picture_url := ""
var _state_info = null
var _home_zone = null
## Zoom steps the user added with the +/- buttons on top of the automatic zoom.
var _zoom_offset := 0.0
var _auto_zoom := DEFAULT_ZOOM

func _ready():
	super()
	icon.value = "person" if entity_id.begins_with("person.") else "location_on"
	_build()
	_build_settings()

	R.effect(func(_arg):
		if show_settings.value:
			if settings.get_parent() == null:
				add_child(settings)
		elif settings.get_parent() == self:
			remove_child(settings)
			camera_follower.reset()
			if App.house != null:
				App.house.save_all_entities()
	)

	R.effect(func(_arg):
		use_3d_map.value
		_update_map()
	)

	_home_zone = await HomeApi.get_state("zone.home")
	set_state(await HomeApi.get_state(entity_id))

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)
	await HomeApi.watch_state("zone.home", func(new_state):
		_home_zone = new_state
		_update_map()
	)

func _build():
	UI.card(self, Vector2(WIDTH, HEIGHT))
	var top = HEIGHT / 2.0 - 0.012 - AVATAR_SIZE / 2.0
	var left = -WIDTH / 2.0 + 0.012

	avatar = MeshInstance3D.new()
	avatar.mesh = QuadMesh.new()
	avatar.mesh.size = Vector2(AVATAR_SIZE, AVATAR_SIZE)
	var material = ShaderMaterial.new()
	material.shader = MarkerShader
	material.render_priority = 13
	material.set_shader_parameter("color", ACCENT)
	material.set_shader_parameter("border", 0.08)
	avatar.material_override = material
	avatar.position = Vector3(left + AVATAR_SIZE / 2.0, top, 0.001)
	add_child(avatar)
	avatar_label = UI.label(self, "", 16, avatar.position + Vector3(0, 0, 0.001), HORIZONTAL_ALIGNMENT_CENTER)

	var text_left = left + AVATAR_SIZE + 0.01
	name_label = UI.label(self, entity_id, 22, Vector3(text_left, top + 0.007, 0))
	state_label = UI.label(self, "", 16, Vector3(text_left, top - 0.011, 0))
	state_label.modulate = Color(1, 1, 1, 0.75)

	map = MapView.new()
	map.size = MAP_SIZE
	map.position = Vector3(0, -HEIGHT / 2.0 + 0.01 + MAP_SIZE.y / 2.0, 0.001)
	add_child(map)

	# The diorama hangs from the top edge of the map area and tilts towards the viewer.
	map_3d = Map3D.new()
	map_3d.size = MAP_3D_SIZE
	map_3d.position = Vector3(0, map.position.y + MAP_SIZE.y / 2.0, 0.002)
	map_3d.visible = false
	add_child(map_3d)

	no_location_label = UI.label(self, "No location", 18, map.position + Vector3(0, 0, 0.001), HORIZONTAL_ALIGNMENT_CENTER)
	no_location_label.modulate = Color(1, 1, 1, 0.6)

	zoom_in = UI.icon_button(self, "add", Vector3.ZERO, 0.022, true)
	zoom_out = UI.icon_button(self, "remove", Vector3.ZERO, 0.022, true)
	zoom_in.on_button_down.connect(func(): _change_zoom(1))
	zoom_out.on_button_down.connect(func(): _change_zoom(-1))
	recenter = UI.icon_button(self, "my_location", Vector3.ZERO, 0.022)
	recenter.on_button_up.connect(func():
		_pan_center = null
		_update_map()
	)

	add_child(pan)
	pan.changed.connect(func(new_center, new_zoom):
		_pan_center = new_center
		_zoom_offset = new_zoom - _auto_zoom
		_update_map()
	)

	add_child(picture_request)

func _build_settings():
	settings = Node3D.new()
	settings.position = Vector3(WIDTH / 2.0 + 0.01 + SETTINGS_SIZE.x / 2.0, HEIGHT / 2.0 - SETTINGS_SIZE.y / 2.0, 0)
	UI.glass(settings, SETTINGS_SIZE)
	var left = -SETTINGS_SIZE.x / 2.0 + 0.012
	var right = SETTINGS_SIZE.x / 2.0 - 0.02
	UI.label(settings, "Map Settings", 18, Vector3(left, SETTINGS_SIZE.y / 2.0 - 0.018, 0))
	UI.label(settings, "3D map:", 16, Vector3(left, -0.012, 0))

	var close = UI.icon_button(settings, "close", Vector3(right, SETTINGS_SIZE.y / 2.0 - 0.018, 0), 0.025)
	close.on_button_up.connect(func(): show_settings.value = false)

	var toggle: Button3D = UI.icon_button(settings, "close", Vector3(right, -0.012, 0), 0.025)
	toggle.toggleable = true
	R.bind(toggle, "active", use_3d_map, toggle.on_toggled)
	R.effect(func(_arg):
		toggle.label = "check" if use_3d_map.value else "close"
	)

func get_options():
	return {"map_3d": use_3d_map.value}

func set_options(options):
	if options.has("map_3d"): use_3d_map.value = options["map_3d"]

func set_state(state_info):
	if state_info == null:
		return
	_state_info = state_info

	var state = str(state_info["state"])
	var attributes = UI.attributes_of(state_info)
	var person_name = UI.entity_name(entity_id, attributes)

	name_label.text = person_name
	state_label.text = _state_text(state)
	avatar_label.text = _initials(person_name)

	var picture_url = attributes.get("entity_picture")
	_load_picture(str(picture_url) if picture_url != null else "")

	_update_map()

func _update_map():
	if _state_info == null:
		return

	var state = str(_state_info["state"])
	var attributes = UI.attributes_of(_state_info)
	var location = _location(attributes)
	var accuracy = float(attributes.get("gps_accuracy", 0)) if attributes.get("gps_accuracy") != null else 0.0

	# Trackers without GPS (e.g. router based) only know home / not home.
	# Like Home Assistant, show them at the home zone while they are home.
	var home = _location(UI.attributes_of(_home_zone))
	if location == null and state == "home" and home != null:
		location = home
		accuracy = 0.0

	var has_location = location != null
	var in_3d = use_3d_map.value
	map.visible = has_location and not in_3d
	map_3d.visible = has_location and in_3d
	no_location_label.visible = not has_location
	zoom_in.visible = has_location
	zoom_out.visible = has_location
	zoom_in.disabled = not has_location
	zoom_out.disabled = not has_location
	recenter.visible = has_location and _pan_center != null
	recenter.disabled = not recenter.visible
	_place_zoom_buttons(in_3d)
	if not has_location:
		pan.stop()
		return

	var circles = []
	var markers = []

	var home_attributes = UI.attributes_of(_home_zone)
	if home != null:
		circles.append({"lat": home.x, "lon": home.y, "radius": float(home_attributes.get("radius", 100)), "color": HOME_ZONE_COLOR})
		markers.append({"lat": home.x, "lon": home.y, "text": "home", "icon": true, "color": Color(0.85, 0.5, 0.0), "diameter": 0.018})

	if accuracy > 0:
		circles.append({"lat": location.x, "lon": location.y, "radius": accuracy, "color": ACCURACY_COLOR})

	markers.append({"lat": location.x, "lon": location.y, "texture": picture, "text": avatar_label.text, "color": ACCENT, "diameter": 0.028})

	# Fit home and the position together when they're close enough, like Home
	# Assistant's map fits its markers; otherwise centre on the position. The 3D
	# map starts closer, so houses are shown (they appear from zoom 15).
	var auto_zoom = DEFAULT_ZOOM_3D if in_3d else DEFAULT_ZOOM
	var center = location
	if home != null:
		var fit = map.fit_zoom([home, location])
		if fit >= MIN_FIT_ZOOM:
			auto_zoom = fit
			# Zoomed in past the fit, the midpoint would push both markers off the
			# map, so then follow the position instead.
			if _zoom_offset <= 0:
				center = (home + location) / 2.0
	_auto_zoom = auto_zoom
	if _pan_center != null:
		center = _pan_center

	var view = map_3d if in_3d else map
	view.circles = circles
	view.markers = markers
	view.center = center
	view.set_fractional_zoom(auto_zoom + _zoom_offset)
	view.refresh()

## On the flat map the zoom buttons sit in its corner; the diorama would cover
## them there, so in 3D they move up next to the name.
func _place_zoom_buttons(in_3d: bool):
	if in_3d:
		var y = HEIGHT / 2.0 - 0.012 - AVATAR_SIZE / 2.0
		zoom_in.position = Vector3(WIDTH / 2.0 - 0.024, y, 0.004)
		zoom_out.position = Vector3(WIDTH / 2.0 - 0.05, y, 0.004)
		recenter.position = Vector3(WIDTH / 2.0 - 0.076, y, 0.004)
	else:
		var x = MAP_SIZE.x / 2.0 - 0.018
		var y = map.position.y + MAP_SIZE.y / 2.0 - 0.018
		zoom_in.position = Vector3(x, y, 0.004)
		zoom_out.position = Vector3(x, y - 0.026, 0.004)
		recenter.position = Vector3(x, y - 0.052, 0.004)

## Pressing the map (not a button on it) starts dragging it; a second hand zooms.
func _on_press_down(event: EventPointer):
	if event.target in [self, map.body, map_3d.body]:
		pan.start(event, map_3d if use_3d_map.value else map)

func _on_press_up(event: EventPointer):
	pan.stop(event)

func _change_zoom(direction: int):
	# Keep the offset within the zoom limits, so zooming back works right away.
	# Buttons step to the next whole level, also after a pinch left it in between.
	_zoom_offset = clampi(roundi(_auto_zoom + _zoom_offset) + direction, Tiles.MIN_ZOOM, Tiles.MAX_ZOOM) - _auto_zoom
	_update_map()

static func _location(attributes: Dictionary):
	if attributes.get("latitude") == null or attributes.get("longitude") == null:
		return null
	return Vector2(float(attributes["latitude"]), float(attributes["longitude"]))

static func _state_text(state: String) -> String:
	match state:
		"home": return "Home"
		"not_home": return "Away"
		"unknown", "unavailable": return state.capitalize()
	return state # zone name, e.g. "Work"

static func _initials(text: String) -> String:
	var words = text.split(" ", false)
	var result = ""
	for word in words.slice(0, 2):
		result += word.substr(0, 1).to_upper()
	return result

# ---------------------------------------------------------------------------
# Picture
# ---------------------------------------------------------------------------

func _load_picture(url: String):
	if url.begins_with("/"):
		var base = HomeApi.get_http_url()
		url = base + url if base != "" else ""

	if url == _picture_url:
		return
	_picture_url = url
	picture_request.cancel_request()

	if url == "":
		_set_picture(null)
		return

	picture_request.request(url)
	var result = await picture_request.request_completed
	if url != _picture_url:
		return # a newer picture was requested meanwhile

	var image = Image.new()
	if result[0] != HTTPRequest.RESULT_SUCCESS or result[1] != 200 \
			or (image.load_jpg_from_buffer(result[3]) != OK and image.load_png_from_buffer(result[3]) != OK and image.load_webp_from_buffer(result[3]) != OK):
		_set_picture(null) # keep the initials
		return

	_set_picture(ImageTexture.create_from_image(_square(image)))

func _set_picture(texture: Texture2D):
	picture = texture
	var material: ShaderMaterial = avatar.material_override
	material.set_shader_parameter("has_picture", texture != null)
	material.set_shader_parameter("picture", texture)
	avatar_label.visible = texture == null
	_update_map()

## Crops to a centred square so the round marker isn't stretched.
static func _square(image: Image) -> Image:
	var side = mini(image.get_width(), image.get_height())
	return image.get_region(Rect2i(floori((image.get_width() - side) / 2.0), floori((image.get_height() - side) / 2.0), side, side))
