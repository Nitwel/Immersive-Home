extends Entity
## person / device_tracker: who it is, where they are ("Home", "Away" or a zone
## name) and a map like Home Assistant's map card, with the home zone and the
## GPS accuracy around the position.

const Entity = preload ("../entity.gd")
const UI = preload ("../entity_ui.gd")
const MapView = preload ("./map_view.gd")
const Tiles = preload ("./map_tiles.gd")
const MarkerShader = preload ("./marker.gdshader")

const WIDTH = 0.30
const HEIGHT = 0.28
const MAP_SIZE = Vector2(0.28, 0.19)
const AVATAR_SIZE = 0.036
## Zoom used when only the position is shown (home is too far away to fit).
const DEFAULT_ZOOM = 14
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
var no_location_label: Label3D
var zoom_in: Button3D
var zoom_out: Button3D
var picture_request := HTTPRequest.new()

var picture: Texture2D = null
var _picture_url := ""
var _state_info = null
var _home_zone = null
## Zoom steps the user added with the +/- buttons on top of the automatic zoom.
var _zoom_offset := 0
var _auto_zoom := DEFAULT_ZOOM

func _ready():
	super()
	icon.value = "person" if entity_id.begins_with("person.") else "location_on"
	_build()

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

	no_location_label = UI.label(self, "No location", 18, map.position + Vector3(0, 0, 0.001), HORIZONTAL_ALIGNMENT_CENTER)
	no_location_label.modulate = Color(1, 1, 1, 0.6)

	var button_x = MAP_SIZE.x / 2.0 - 0.018
	var button_y = map.position.y + MAP_SIZE.y / 2.0 - 0.018
	zoom_in = UI.icon_button(self, "add", Vector3(button_x, button_y, 0.004), 0.022, true)
	zoom_out = UI.icon_button(self, "remove", Vector3(button_x, button_y - 0.026, 0.004), 0.022, true)
	zoom_in.on_button_down.connect(func(): _change_zoom(1))
	zoom_out.on_button_down.connect(func(): _change_zoom(-1))

	add_child(picture_request)

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
	map.visible = has_location
	no_location_label.visible = not has_location
	zoom_in.visible = has_location
	zoom_out.visible = has_location
	zoom_in.disabled = not has_location
	zoom_out.disabled = not has_location
	if not has_location:
		return

	map.circles = []
	map.markers = []

	var home_attributes = UI.attributes_of(_home_zone)
	if home != null:
		map.circles.append({"lat": home.x, "lon": home.y, "radius": float(home_attributes.get("radius", 100)), "color": HOME_ZONE_COLOR})
		map.markers.append({"lat": home.x, "lon": home.y, "text": "home", "icon": true, "color": Color(0.85, 0.5, 0.0), "diameter": 0.018})

	if accuracy > 0:
		map.circles.append({"lat": location.x, "lon": location.y, "radius": accuracy, "color": ACCURACY_COLOR})

	map.markers.append({"lat": location.x, "lon": location.y, "texture": picture, "text": avatar_label.text, "color": ACCENT, "diameter": 0.028})

	# Fit home and the position together when they're close enough, like Home
	# Assistant's map fits its markers; otherwise centre on the position.
	var auto_zoom = DEFAULT_ZOOM
	map.center = location
	if home != null:
		var fit = map.fit_zoom([home, location])
		if fit >= MIN_FIT_ZOOM:
			auto_zoom = fit
			# Zoomed in past the fit, the midpoint would push both markers off the
			# map, so then follow the position instead.
			if _zoom_offset <= 0:
				map.center = (home + location) / 2.0
	_auto_zoom = auto_zoom
	map.zoom = clampi(auto_zoom + _zoom_offset, Tiles.MIN_ZOOM, Tiles.MAX_ZOOM)
	map.refresh()

func _change_zoom(direction: int):
	# Keep the offset within the zoom limits, so zooming back works right away.
	_zoom_offset = clampi(_auto_zoom + _zoom_offset + direction, Tiles.MIN_ZOOM, Tiles.MAX_ZOOM) - _auto_zoom
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
