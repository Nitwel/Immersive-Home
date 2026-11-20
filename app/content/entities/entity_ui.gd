extends RefCounted
## Builders for the glass-card look shared by the code-built entities
## (select, climate, lock, text, date/time). Matches the timer entity's styling.

const PanelScene = preload ("res://content/ui/components/panel/panel.tscn")
const ButtonScene = preload ("res://content/ui/components/button/button.tscn")
const SelectScene = preload ("res://content/ui/components/select/select.tscn")
const InputScene = preload ("res://content/ui/components/input/input.tscn")
const SliderScene = preload ("res://content/ui/components/slider/slider.tscn")
const IconFont = preload ("res://assets/icons/icons.tres")
## Label3D's font when none is set (the project's theme font).
const DefaultFont = preload ("res://assets/fonts/Montserrat-Medium.ttf")
const DeviceUtils = preload ("res://content/ui/menu/edit/device_utils.gd")

## Glass card of [param size] centred on the parent; also sizes the entity's collision
## shape so the whole card can be grabbed and moved.
static func card(entity: Node3D, size: Vector2) -> Panel3D:
	var panel: Panel3D = PanelScene.instantiate()
	panel.size = size
	panel.corner_radius = 0.012
	entity.add_child(panel)

	var collision: CollisionShape3D = entity.get_node("CollisionShape3D")
	collision.shape = BoxShape3D.new()
	resize_card(entity, panel, size)
	return panel

## Changes the card (and grab shape) to [param size], centred at [param center_y].
## Used by widgets that drop rows for features a device doesn't support.
static func resize_card(entity: Node3D, panel: Panel3D, size: Vector2, center_y := 0.0):
	panel.size = size
	panel.position.y = center_y
	var collision: CollisionShape3D = entity.get_node("CollisionShape3D")
	collision.shape.size = Vector3(size.x, size.y, 0.02)
	collision.position = Vector3(0, center_y, -0.01)

static func label(parent: Node3D, text: String, font_size: int, position: Vector3, alignment := HORIZONTAL_ALIGNMENT_LEFT, icon := false) -> Label3D:
	var node = Label3D.new()
	node.text = text
	node.pixel_size = 0.001
	node.font_size = font_size
	node.outline_size = 0
	node.render_priority = 15
	node.outline_render_priority = 14
	node.horizontal_alignment = alignment
	node.position = position
	if icon:
		node.font = IconFont
	parent.add_child(node)
	return node

## Icon button; [param size] is the square edge length.
static func icon_button(parent: Node3D, icon_name: String, position: Vector3, size := 0.03, echo := false) -> Button3D:
	var button: Button3D = ButtonScene.instantiate()
	button.size = Vector3(size, size, 0.01)
	button.label = icon_name
	button.icon = true
	button.echo = echo
	button.position = position
	parent.add_child(button)
	return button

static func select(parent: Node3D, position: Vector3, width: float) -> Select3D:
	var node: Select3D = SelectScene.instantiate()
	node.size = Vector3(width, 0.03, 0.01)
	node.position = position
	parent.add_child(node)
	return node

## Horizontal slider without the value label (the widgets show the value themselves).
static func slider(parent: Node3D, position: Vector3, width: float, min_value := 0.0, max_value := 100.0, step := 1.0) -> Slider3D:
	var node: Slider3D = SliderScene.instantiate()
	node.position = position
	node.show_label = false
	parent.add_child(node)
	node.size = Vector3(width, 0.02, 0.01)
	node.step = step
	node.min = min_value
	node.max = max_value
	return node

static func input(parent: Node3D, position: Vector3, width: float) -> Input3D:
	var node: Input3D = InputScene.instantiate()
	node.size = Vector3(width, 0.03, 0.01)
	node.position = position
	parent.add_child(node)
	return node

## friendly_name, or the entity id when Home Assistant doesn't send one.
static func entity_name(entity_id: String, attributes: Dictionary) -> String:
	var name = attributes.get("friendly_name")
	return str(name) if name != null else entity_id

## Shortens [param text] with an ellipsis so [param node] stays within [param max_width] meters.
static func fit_label(node: Label3D, text: String, max_width: float):
	var font = node.font if node.font != null else DefaultFont
	node.text = DeviceUtils.fit_text(text, node.font_size, max_width, font)

## The option to select in a dropdown: [param value] if it is one of [param options], else null.
static func option_or_null(options: Dictionary, value):
	return value if options.has(value) else null

## Attributes of a state dictionary, never null.
static func attributes_of(state_info) -> Dictionary:
	if state_info == null:
		return {}
	var attributes = state_info.get("attributes", {})
	return attributes if attributes is Dictionary else {}

static func is_unavailable(state: String) -> bool:
	return state == "unavailable"||state == "unknown"

## supported_features bitmask, or [param fallback] when Home Assistant doesn't send it.
static func features_of(attributes: Dictionary, fallback: int) -> int:
	var features = attributes.get("supported_features")
	return int(features) if features != null else fallback

## Shows or hides a control. Hidden controls are also disabled, so their
## collision shapes stop catching rays and touches.
static func set_shown(node: Node3D, shown: bool):
	node.visible = shown
	node.process_mode = Node.PROCESS_MODE_INHERIT if shown else Node.PROCESS_MODE_DISABLED

## Dims a button's icon, e.g. while it can't be used.
static func dim_button(button: Button3D, dimmed: bool):
	button.get_node("Body/Label").modulate = Color(1, 1, 1, 0.4 if dimmed else 1.0)

## Makes [param node] wrap its text at [param width] meters.
static func wrap(node: Label3D, width: float):
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.width = width / node.pixel_size

# ---------------------------------------------------------------------------
# Time
# ---------------------------------------------------------------------------

## Seconds to add to a UTC unix time to get the local wall clock.
static func utc_offset() -> int:
	return int(Time.get_time_zone_from_system().bias) * 60

## Unix time (UTC) of a Home Assistant timestamp, or -1. Accepts
## "2026-11-20T10:00:00.123+01:00", "...Z", local "2026-11-20 10:00:00" and dates.
static func parse_timestamp(value) -> int:
	if value == null:
		return -1
	var text = str(value).strip_edges()
	if text.length() == 10:
		text += "T00:00:00"
	if text.length() < 19:
		return -1

	var unix = Time.get_unix_time_from_datetime_string(text.substr(0, 19).replace(" ", "T"))
	var rest = text.substr(19)
	if rest.begins_with("."):
		var i = 1
		while i < rest.length() and rest[i].is_valid_int():
			i += 1
		rest = rest.substr(i)

	if rest == "":
		return unix - utc_offset()
	if rest == "Z":
		return unix
	var parts = rest.substr(1).split(":")
	var offset = int(parts[0]) * 3600 + (int(parts[1]) * 60 if parts.size() > 1 else 0)
	return unix - offset if rest.begins_with("+") else unix + offset

## Local "18:42" for a unix time.
static func format_clock(unix: int) -> String:
	var d = Time.get_datetime_dict_from_unix_time(unix + utc_offset())
	return "%02d:%02d" % [d.hour, d.minute]

const WEEKDAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

## "Today", "Tomorrow", "Yesterday" or "Fri 21 Nov" for a unix time.
static func format_day(unix: int) -> String:
	var local = unix + utc_offset()
	var today = floori((Time.get_unix_time_from_system() + utc_offset()) / 86400.0)
	var day = floori(local / 86400.0)
	match day - today:
		0: return "Today"
		1: return "Tomorrow"
		-1: return "Yesterday"
	var d = Time.get_datetime_dict_from_unix_time(local)
	return "%s %d %s" % [WEEKDAYS[d.weekday], d.day, MONTHS[d.month - 1]]

## "just now", "5 min ago", "3 h ago", "2 days ago" (or "in ..." for the future).
static func format_relative(unix: int) -> String:
	var delta = int(Time.get_unix_time_from_system()) - unix
	var future = delta < 0
	delta = abs(delta)
	var text: String
	if delta < 60:
		return "just now"
	elif delta < 3600:
		text = "%d min" % floori(delta / 60.0)
	elif delta < 86400:
		text = "%d h" % floori(delta / 3600.0)
	else:
		var days = floori(delta / 86400.0)
		text = "%d day%s" % [days, "" if days == 1 else "s"]
	return "in " + text if future else text + " ago"

# ---------------------------------------------------------------------------
# Images
# ---------------------------------------------------------------------------

## Downloads an image from Home Assistant ([param path] like "/api/image_proxy/...").
## Returns null on failure. "res://" paths load a local texture (used by the gallery).
static func load_image(http_request: HTTPRequest, path: String) -> Texture2D:
	if path.begins_with("res://"):
		return load(path) if ResourceLoader.exists(path) else null

	if http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return null
	var url = path if path.begins_with("http") else HomeApi.get_http_url() + path
	if http_request.request(url) != OK:
		return null

	var result = await http_request.request_completed
	if result[0] != HTTPRequest.RESULT_SUCCESS or result[1] != 200:
		return null

	var content_type = "image/png"
	for header in result[2]:
		if header.to_lower().begins_with("content-type:"):
			content_type = header.substr(13).strip_edges().split(";")[0]

	var image = Image.new()
	var error = ERR_FILE_UNRECOGNIZED
	match content_type:
		"image/png": error = image.load_png_from_buffer(result[3])
		"image/jpeg", "image/jpg": error = image.load_jpg_from_buffer(result[3])
		"image/webp": error = image.load_webp_from_buffer(result[3])
		"image/bmp": error = image.load_bmp_from_buffer(result[3])
	if error != OK:
		return null
	return ImageTexture.create_from_image(image)
