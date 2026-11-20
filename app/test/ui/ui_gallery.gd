extends Node3D
## Desktop gallery for the 3D UI components.
##
## Lays every component out on a wall in front of a regular Camera3D and drives
## the real EventSystem pointer pipeline from the mouse, so components react
## exactly like they do with an XR controller ray.
##
## Controls:
##   Left mouse        - trigger (press / click / drag sliders)
##   Right mouse       - grip (grab)
##   Middle drag       - orbit, Shift + middle drag - pan
##   Mouse wheel       - zoom
##   1..9              - focus a component cell, 0 / F - show everything
##   F1                - while an input is focused: type with the PC keyboard
##   P                 - save a screenshot to user://ui_gallery/
##
## Command line (after `--`):
##   --screenshot=<path.png>   render, save the image and quit
##   --focus=<cell name>       frame a single cell (e.g. --focus=slider)
##   --size=<w>x<h>            window size, default 1600x1000
##   --delay=<seconds>         wait before the screenshot, default 1.0
##   --click=<x>,<y>[;<x>,<y>] left-click these window pixels before the
##                             screenshot (e.g. to capture an open Select)
##   --type=<text>             after the clicks, type this text with virtual
##                             keyboard events (click an Input first to focus it);
##                             "{backspace}" sends a backspace, "{enter}" an enter
##   --grab=<x>,<y>><x>,<y>    after the clicks, press grip at the first pixel and
##                             drag to the second, still holding it for the
##                             screenshot (add --release to let go first)
##   --drag=<x>,<y>><x>,<y>    the same with the trigger (e.g. to pan a map)
##   --pinch=<x>,<y>><x>,<y>;<x>,<y>><x>,<y>
##                             two hands: trigger drags of a second pointer (left
##                             controller) and the main one at the same time, e.g. to
##                             zoom a map (add --release to let go first)
##   --input-delay=<seconds>   wait before the scripted input, default 0.3

const Pointer = preload ("res://lib/utils/pointer/pointer.gd")
const Initiator = preload ("res://lib/utils/pointer/initiator.gd")

const ButtonScene = preload ("res://content/ui/components/button/button.tscn")
const InputScene = preload ("res://content/ui/components/input/input.tscn")
const SliderScene = preload ("res://content/ui/components/slider/slider.tscn")
const SelectScene = preload ("res://content/ui/components/select/select.tscn")
const TabsScene = preload ("res://content/ui/components/tabs/tabs.tscn")
const PaginationScene = preload ("res://content/ui/components/pagination/pagination.tscn")
const ColorWheelScene = preload ("res://content/ui/components/color_wheel/color_wheel.tscn")
const LineChartScene = preload ("res://content/ui/components/line_chart/line_chart.tscn")
const NotificationScene = preload ("res://content/ui/components/notification/notification.tscn")
const LabelContainerScene = preload ("res://content/ui/components/label_container/label_container.tscn")
const PanelScene = preload ("res://content/ui/components/panel/panel.tscn")
const KeyboardScene = preload ("res://content/system/keyboard/keyboard.tscn")

const CELL_SIZE = Vector2(0.6, 0.4)
const COLUMNS = 3
const CAMERA_FOV = 40.0

@onready var camera: Camera3D = $Camera3D
@onready var ray: RayCast3D = $Camera3D/RayCast3D
@onready var cells_root: Node3D = $Cells
@onready var status_label: Label = $HUD/Status

var pointer: Pointer
var cells: Array[Node3D] = []

# Orbit camera state
var orbit_target := Vector3.ZERO
var orbit_yaw := 0.0
var orbit_pitch := 0.0
var orbit_distance := 1.5

var _args := {}

func _ready():
	_args = _parse_args()

	# The project renders with a transparent background for passthrough; the
	# gallery wants an opaque backdrop so screenshots aren't see-through.
	get_viewport().transparent_bg = false

	var parts = String(_args.get("size", "1600x1000")).split("x")
	get_window().size = Vector2i(int(parts[0]), int(parts[1]))
	get_window().move_to_center()
	await get_tree().process_frame # let the viewport pick up the new size before framing

	camera.fov = CAMERA_FOV
	_setup_pointer()
	_build_gallery()

	if _args.has("focus"):
		_focus_cell_by_name(_args["focus"])
	else:
		_focus_all()

	if _args.has("screenshot"):
		_take_screenshot_and_quit(_args["screenshot"], float(_args.get("delay", "1.0")))

func _parse_args() -> Dictionary:
	var result := {}
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var kv = arg.substr(2).split("=", true, 1)
			result[kv[0]] = kv[1] if kv.size() > 1 else "true"
	return result

# ---------------------------------------------------------------------------
# Pointer: mouse -> RayCast3D -> Pointer -> EventSystem
# ---------------------------------------------------------------------------

func _setup_pointer():
	var initiator = Initiator.new()
	initiator.type = Initiator.Type.CONTROLLER_RIGHT
	initiator.node = camera

	pointer = Pointer.new(initiator, ray)
	ray.add_child(pointer)

func _physics_process(_delta):
	_aim_ray_at_mouse()

var _scripted_mouse = null # Vector2 while a --click is being replayed

func _aim_ray_at_mouse():
	var mouse = _scripted_mouse if _scripted_mouse != null else get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse)
	var dir = camera.project_ray_normal(mouse)

	# The ray's -Z must point along the mouse ray; components read
	# event.ray.global_transform.basis.z to compute drag positions.
	ray.global_transform = Transform3D(Basis.looking_at(dir, Vector3.UP), origin)
	ray.target_position = Vector3(0, 0, -20)
	ray.force_raycast_update()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_aim_ray_at_mouse()
				if event.pressed: pointer.pressed(Initiator.EventType.TRIGGER)
				else: pointer.released(Initiator.EventType.TRIGGER)
			MOUSE_BUTTON_RIGHT:
				_aim_ray_at_mouse()
				if event.pressed: pointer.pressed(Initiator.EventType.GRIP)
				else: pointer.released(Initiator.EventType.GRIP)
			MOUSE_BUTTON_WHEEL_UP:
				orbit_distance = max(0.1, orbit_distance * 0.9)
				_update_camera()
			MOUSE_BUTTON_WHEEL_DOWN:
				orbit_distance = min(10.0, orbit_distance * 1.1)
				_update_camera()

	elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
		if event.shift_pressed:
			# World units per pixel at the orbit target, so the content tracks the cursor.
			var pan = 2.0 * orbit_distance * tan(deg_to_rad(camera.fov) / 2.0) / get_viewport().get_visible_rect().size.y
			orbit_target += camera.global_transform.basis * Vector3(-event.relative.x * pan, event.relative.y * pan, 0)
		else:
			orbit_yaw -= event.relative.x * 0.005
			orbit_pitch = clamp(orbit_pitch - event.relative.y * 0.005, -1.4, 1.4)
		_update_camera()

	elif event is InputEventKey and event.pressed and not event.echo:
		# Don't steal keys while an input field is focused (F1 typing mode).
		if EventSystem.get_focused() is Input3D:
			return

		match event.keycode:
			KEY_P:
				_save_screenshot("user://ui_gallery/%s.png" % Time.get_datetime_string_from_system().replace(":", "-"))
			KEY_F, KEY_0:
				_focus_all()
			_:
				var index = event.keycode - KEY_1
				if index >= 0 and index < cells.size():
					_focus_cell(cells[index])

func _update_camera():
	var offset = Basis.from_euler(Vector3(orbit_pitch, orbit_yaw, 0)) * Vector3(0, 0, orbit_distance)
	camera.global_transform = Transform3D(Basis.IDENTITY, orbit_target + offset).looking_at(orbit_target, Vector3.UP)

func _frame(center: Vector3, extent: Vector2):
	var aspect = float(get_viewport().get_visible_rect().size.x) / get_viewport().get_visible_rect().size.y
	var half_v = deg_to_rad(CAMERA_FOV) / 2.0
	var dist_v = (extent.y / 2.0) / tan(half_v)
	var dist_h = (extent.x / 2.0) / (tan(half_v) * aspect)

	orbit_target = center
	orbit_yaw = 0
	orbit_pitch = 0
	orbit_distance = max(dist_v, dist_h) * 1.1
	_update_camera()

func _focus_all():
	var rows = ceil(cells.size() / float(COLUMNS))
	var extent = Vector2(COLUMNS * CELL_SIZE.x, rows * CELL_SIZE.y)
	_frame(Vector3(extent.x / 2.0, -extent.y / 2.0, 0), extent)

func _focus_cell(cell: Node3D):
	_frame(cell.position + Vector3(CELL_SIZE.x / 2.0, -CELL_SIZE.y / 2.0, 0), CELL_SIZE)

func _focus_cell_by_name(cell_name: String):
	for cell in cells:
		if cell.name.to_lower() == cell_name.to_lower():
			_focus_cell(cell)
			return
	push_warning("ui_gallery: no cell named '%s'. Available: %s" % [cell_name, ", ".join(cells.map(func(c): return c.name))])
	_focus_all()

# ---------------------------------------------------------------------------
# Screenshots
# ---------------------------------------------------------------------------

func _save_screenshot(path: String):
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var image = get_viewport().get_texture().get_image()
	image.convert(Image.FORMAT_RGB8)
	var err = image.save_png(path)
	var abs_path = ProjectSettings.globalize_path(path)
	if err == OK:
		print("ui_gallery: saved screenshot to ", abs_path)
		status_label.text = "Saved " + abs_path
	else:
		push_error("ui_gallery: failed to save screenshot to %s (%s)" % [abs_path, error_string(err)])

func _take_screenshot_and_quit(path: String, delay: float):
	# Scripted input waits for the layout to settle (--input-delay, seconds).
	if _args.has("click") or _args.has("grab") or _args.has("drag") or _args.has("pinch"):
		await get_tree().create_timer(float(_args.get("input-delay", "0.3"))).timeout
	if _args.has("click"):
		for pair in String(_args["click"]).split(";"):
			var xy = pair.split(",")
			await _scripted_click(Vector2(float(xy[0]), float(xy[1])))
		_scripted_mouse = null

	if _args.has("type"):
		await _scripted_type(_args["type"])

	if _args.has("grab"):
		var points = String(_args["grab"]).split(">")
		await _scripted_grab(_pixel(points[0]), _pixel(points[1]), _args.has("release"))

	if _args.has("drag"):
		var points = String(_args["drag"]).split(">")
		await _scripted_grab(_pixel(points[0]), _pixel(points[1]), _args.has("release"), Initiator.EventType.TRIGGER)

	if _args.has("pinch"):
		var hands = String(_args["pinch"]).split(";")
		var a = hands[0].split(">")
		var b = hands[1].split(">")
		await _scripted_pinch(_pixel(a[0]), _pixel(a[1]), _pixel(b[0]), _pixel(b[1]), _args.has("release"))

	# Let tweens/animations (button press depth, notification fade-in) settle.
	await get_tree().create_timer(delay).timeout
	await RenderingServer.frame_post_draw
	if not path.is_absolute_path() and not path.begins_with("res://") and not path.begins_with("user://"):
		path = OS.get_environment("PWD").path_join(path) if OS.has_environment("PWD") else path
	_save_screenshot(path)
	get_tree().quit()

## Simulates hover + trigger press/release at a window pixel position.
func _scripted_click(pos: Vector2):
	_scripted_mouse = pos
	for i in 3: await get_tree().physics_frame # hover (ray_enter)
	_aim_ray_at_mouse()
	pointer.pressed(Initiator.EventType.TRIGGER)
	await get_tree().physics_frame
	pointer.released(Initiator.EventType.TRIGGER)
	for i in 3: await get_tree().physics_frame

func _pixel(text: String) -> Vector2:
	var xy = text.split(",")
	return Vector2(float(xy[0]), float(xy[1]))

## Presses grip (or [param type]) at [param from] and drags the pointer to [param to].
## The mouse stays scripted afterwards so the ray keeps pointing at [param to].
func _scripted_grab(from: Vector2, to: Vector2, release: bool, type := Initiator.EventType.GRIP):
	_scripted_mouse = from
	for i in 3: await get_tree().physics_frame
	_aim_ray_at_mouse()
	print("ui_gallery: pressing on %s (%s) at %s" % [ray.get_collider(), ray.get_collider().get_parent().name if ray.get_collider() else "", ray.get_collision_point()])
	pointer.pressed(type)
	for i in 20:
		_scripted_mouse = from.lerp(to, (i + 1) / 20.0)
		await get_tree().physics_frame
	if release:
		pointer.released(type)
		for i in 3: await get_tree().physics_frame

## Drags a second pointer from [param a_from] to [param a_to] and the main one from
## [param b_from] to [param b_to], both holding the trigger.
func _scripted_pinch(a_from: Vector2, a_to: Vector2, b_from: Vector2, b_to: Vector2, release: bool):
	var ray2 = RayCast3D.new()
	ray2.collision_mask = ray.collision_mask
	ray2.collide_with_areas = ray.collide_with_areas
	add_child(ray2)
	var initiator2 = Initiator.new()
	initiator2.type = Initiator.Type.CONTROLLER_LEFT
	initiator2.node = ray2
	var pointer2 = Pointer.new(initiator2, ray2)
	ray2.add_child(pointer2)

	var aim2 = func(pos: Vector2):
		ray2.global_transform = Transform3D(Basis.looking_at(camera.project_ray_normal(pos), Vector3.UP), camera.project_ray_origin(pos))
		ray2.target_position = Vector3(0, 0, -20)
		ray2.force_raycast_update()

	_scripted_mouse = b_from
	aim2.call(a_from)
	for i in 3: await get_tree().physics_frame
	_aim_ray_at_mouse()
	aim2.call(a_from)
	pointer2.pressed(Initiator.EventType.TRIGGER)
	pointer.pressed(Initiator.EventType.TRIGGER)
	for i in 30:
		_scripted_mouse = b_from.lerp(b_to, (i + 1) / 30.0)
		aim2.call(a_from.lerp(a_to, (i + 1) / 30.0))
		await get_tree().physics_frame
	if release:
		pointer2.released(Initiator.EventType.TRIGGER)
		pointer.released(Initiator.EventType.TRIGGER)
		for i in 3: await get_tree().physics_frame

## Types [param text] the way the virtual keyboard does (EventKey via EventSystem).
## "{backspace}" in the text sends a backspace key.
func _scripted_type(text: String):
	for c in text.replace("{backspace}", "\b").replace("{enter}", "\n"):
		var key: Key
		match c:
			" ": key = KEY_SPACE
			"\b": key = KEY_BACKSPACE
			"\n": key = KEY_ENTER
			_: key = OS.find_keycode_from_string(c.to_upper())

		var event = EventKey.new()
		event.key = key
		event.shift_pressed = c != c.to_lower()
		EventSystem.emit("key_down", event)
		await get_tree().process_frame
		event = EventKey.new()
		event.key = key
		EventSystem.emit("key_up", event)
		await get_tree().process_frame

# ---------------------------------------------------------------------------
# Gallery content. Add a new component by adding another _add_cell() call.
# ---------------------------------------------------------------------------

func _build_gallery():
	_add_cell("Button", func(root: Node3D):
		var row = _row(root, 0.08)
		var plain = _button("Button", Vector3(0.12, 0.04, 0.01))
		var toggle = _button("Toggle", Vector3(0.12, 0.04, 0.01))
		toggle.toggleable = true
		toggle.initial_active = true
		var disabled = _button("Disabled", Vector3(0.12, 0.04, 0.01))
		disabled.disabled = true
		for b in [plain, toggle, disabled]: row.add_child(b)
		_layout_row(row, 0.02)

		var icons = _row(root, -0.02)
		for icon_name in ["home", "settings", "lightbulb", "close"]:
			var b = _button(icon_name, Vector3(0.05, 0.05, 0.01))
			b.icon = true
			icons.add_child(b)
		_layout_row(icons, 0.02)
	)

	_add_cell("Input", func(root: Node3D):
		var a = InputScene.instantiate()
		a.text = ""
		a.placeholder = "Placeholder"
		a.size = Vector3(0.3, 0.04, 0.01)
		a.position.y = 0.05
		root.add_child(a)

		var b = InputScene.instantiate()
		b.text = "Some text value"
		b.size = Vector3(0.3, 0.04, 0.01)
		root.add_child(b)

		var c = InputScene.instantiate()
		c.text = "Disabled"
		c.disabled = true
		c.size = Vector3(0.3, 0.04, 0.01)
		c.position.y = -0.05
		root.add_child(c)
	)

	_add_cell("Slider", func(root: Node3D):
		var a = SliderScene.instantiate()
		a.size = Vector3(0.3, 0.02, 0.01)
		a.value = 0.3
		a.position.y = 0.04
		root.add_child(a)

		var b = SliderScene.instantiate()
		b.size = Vector3(0.3, 0.02, 0.01)
		b.min = 0
		b.max = 100
		b.step = 1
		b.value = 70
		b.show_label = true
		b.label_unit = "%"
		b.position.y = -0.04
		root.add_child(b)
	)

	_add_cell("Select", func(root: Node3D):
		var s = SelectScene.instantiate()
		s.options = {"living": "Living room", "kitchen": "Kitchen", "bedroom": "Bedroom"}
		s.selected = "living"
		s.position.y = 0.06
		root.add_child(s)
	)

	_add_cell("Tabs", func(root: Node3D):
		var tabs = TabsScene.instantiate()
		tabs.size = Vector3(0.36, 0.04, 0.01)
		tabs.gap = 0.01
		for tab_name in ["Rooms", "Devices", "Settings"]:
			var b = _button(tab_name, Vector3(0.11, 0.04, 0.01))
			tabs.add_child(b)
		tabs.position.x = -0.18
		root.add_child(tabs)
	)

	_add_cell("Pagination", func(root: Node3D):
		var p = PaginationScene.instantiate()
		p.size = Vector3(0.4, 0.05, 0.01)
		p.pages = 12
		p.visible_pages = 5
		p.page = 3
		p.position.x = -0.2
		root.add_child(p)
	)

	_add_cell("ColorWheel", func(root: Node3D):
		var c = ColorWheelScene.instantiate()
		c.color = Color(1.0, 0.6, 0.2)
		root.add_child(c)
	)

	_add_cell("LineChart", func(root: Node3D):
		var chart = LineChartScene.instantiate()
		chart.position = Vector3(-0.25, -0.15, 0)
		root.add_child(chart)
	)

	_add_cell("Notification", func(root: Node3D):
		var y = 0.08
		for t in [EventNotify.Type.INFO, EventNotify.Type.WARNING, EventNotify.Type.DANGER, EventNotify.Type.SUCCESS]:
			var n = NotificationScene.instantiate()
			n.type = t
			n.text = EventNotify.Type.keys()[t].capitalize() + " notification"
			n.position.y = y
			root.add_child(n)
			n.timer.stop() # keep it on screen instead of auto-dismissing
			y -= 0.06
	)

	_add_cell("Panel", func(root: Node3D):
		var a = PanelScene.instantiate()
		a.size = Vector2(0.15, 0.15)
		a.position.x = -0.1
		root.add_child(a)

		var b = PanelScene.instantiate()
		b.size = Vector2(0.15, 0.15)
		b.active = true
		b.position.x = 0.1
		root.add_child(b)
	)

	_add_cell("LabelContainer", func(root: Node3D):
		var l = LabelContainerScene.instantiate()
		l.text = "Label container"
		l.size = Vector3(0.3, 0.05, 0.01)
		root.add_child(l)
	)

	_add_cell("Keyboard", func(root: Node3D):
		var input = InputScene.instantiate()
		input.text = ""
		input.placeholder = "Click here, then type"
		input.size = Vector3(0.4, 0.04, 0.01)
		input.position.y = 0.13
		root.add_child(input)

		var keyboard = KeyboardScene.instantiate()
		keyboard.position.y = -0.03
		root.add_child(keyboard)
		# The keyboard takes itself out of the tree until an input is focused,
		# put it back so it stays visible in the gallery.
		await get_tree().process_frame
		if not keyboard.is_inside_tree():
			root.add_child(keyboard)
	)

	# Glass/border shader on different sizes and non-quad meshes. The border and
	# corners should look identical (same width in meters) on every shape.
	_add_cell("Shapes", func(root: Node3D):
		# Real Panel3D components at different sizes
		var squares: Array = []
		for s in [0.02, 0.04, 0.08, 0.12]:
			var p = PanelScene.instantiate()
			p.size = Vector2(s, s)
			squares.append(["%d cm" % roundi(s * 100), p, s])
		var wide = PanelScene.instantiate()
		wide.size = Vector2(0.16, 0.04)
		squares.append(["Wide", wide, 0.16])
		_shape_row(root, 0.085, 0.06, squares)

		# Custom meshes with the glass material
		var rainbow = _glass_instance(_rainbow_mesh(0.07, 0.035), 0.006)
		rainbow.position.y = -0.035 # centre its bounding box
		var rainbow_root = Node3D.new()
		rainbow_root.add_child(rainbow)
		_shape_row(root, -0.09, 0.05, [
			["Round", _glass_instance(_disc_mesh(0.05), 1.0), 0.1],
			["Concave", _glass_instance(_curved_mesh(Vector2(0.08, 0.1), 0.06, true), 0.006), 0.08],
			["Convex", _glass_instance(_curved_mesh(Vector2(0.08, 0.1), 0.06, false), 0.006), 0.08],
			["Rainbow", rainbow_root, 0.14],
		])
	)

func _add_cell(cell_name: String, build: Callable):
	var index = cells.size()
	var cell = Node3D.new()
	cell.name = cell_name
	cell.position = Vector3((index % COLUMNS) * CELL_SIZE.x, -floori(index / float(COLUMNS)) * CELL_SIZE.y, 0)
	cells_root.add_child(cell)
	cells.append(cell)

	# Faint cell frame + caption
	var frame = MeshInstance3D.new()
	var quad = QuadMesh.new()
	quad.size = CELL_SIZE - Vector2(0.02, 0.02)
	frame.mesh = quad
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1, 1, 1, 0.04)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	frame.material_override = mat
	frame.position = Vector3(CELL_SIZE.x / 2, -CELL_SIZE.y / 2, -0.005)
	cell.add_child(frame)

	var caption = Label3D.new()
	caption.text = "%d  %s" % [index + 1, cell_name]
	caption.font_size = 24
	caption.pixel_size = 0.001
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	caption.modulate = Color(1, 1, 1, 0.6)
	caption.position = Vector3(0.02, -0.025, 0)
	caption.offset = Vector2(0, 0)
	cell.add_child(caption)

	# Components are centred on the cell
	var content = Node3D.new()
	content.name = "Content"
	content.position = Vector3(CELL_SIZE.x / 2, -CELL_SIZE.y / 2 - 0.01, 0)
	cell.add_child(content)
	build.call(content)

func _button(text: String, size: Vector3) -> Button3D:
	var b = ButtonScene.instantiate()
	b.label = text
	b.size = size
	return b

func _row(root: Node3D, y: float) -> Node3D:
	var row = Node3D.new()
	row.position.y = y
	root.add_child(row)
	return row

## Lays out [param items] ([label, node, width]) centred on a row at [param y],
## with a caption under each. [param half_height] is the tallest item's half height.
func _shape_row(root: Node3D, y: float, half_height: float, items: Array, gap := 0.025):
	var row = _row(root, y)
	var total = gap * (items.size() - 1)
	for item in items: total += item[2]
	var x = -total / 2.0
	for item in items:
		x += item[2] / 2.0
		item[1].position.x = x
		row.add_child(item[1])

		var label = Label3D.new()
		label.text = item[0]
		label.font_size = 14
		label.pixel_size = 0.001
		label.modulate = Color(1, 1, 1, 0.6)
		label.position = Vector3(x, -half_height - 0.012, 0)
		row.add_child(label)
		x += item[2] / 2.0 + gap

## MeshInstance3D with the glass material set up like a default Panel3D.
func _glass_instance(mesh: Mesh, corner_radius: float) -> MeshInstance3D:
	var mat: ShaderMaterial = Panel3D.PanelMaterial.duplicate()
	mat.set_shader_parameter("color", Panel3D.COLOR)
	mat.set_shader_parameter("border_color", Panel3D.BORDER_COLOR)
	mat.set_shader_parameter("corner_radius", corner_radius)
	mat.set_shader_parameter("border_size", 0.6 * Panel3D.BORDER_SIZE)
	mat.set_shader_parameter("border_fade_in", 0.6 * Panel3D.BORDER_FADE_IN)
	var m = MeshInstance3D.new()
	m.mesh = mesh
	m.material_override = mat
	return m

## Flat disc facing +Z with planar UVs (0..1 across the diameter).
func _disc_mesh(radius: float, segments := 48) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var point = func(angle: float):
		var p = Vector2(cos(angle), sin(angle)) * radius
		st.set_normal(Vector3.BACK)
		st.set_uv(Vector2(p.x / (2.0 * radius) + 0.5, 0.5 - p.y / (2.0 * radius)))
		st.add_vertex(Vector3(p.x, p.y, 0))
	for i in segments:
		var a0 = TAU * i / segments
		var a1 = TAU * (i + 1) / segments
		# Clockwise winding seen from +Z (Godot front face)
		st.set_normal(Vector3.BACK)
		st.set_uv(Vector2(0.5, 0.5))
		st.add_vertex(Vector3.ZERO)
		point.call(a1)
		point.call(a0)
	return st.commit()

## Half-ring arc ("rainbow") in the XY plane, centred on the origin. U runs
## along the arc (left to right), V across the band (outer to inner).
func _rainbow_mesh(outer_radius: float, band: float, segments := 64, rings := 8) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var vert = func(u: float, v: float):
		var angle = PI * (1.0 - u)
		var r = outer_radius - v * band
		st.set_normal(Vector3.BACK)
		st.set_uv(Vector2(u, v))
		st.add_vertex(Vector3(cos(angle) * r, sin(angle) * r, 0))
	for i in segments:
		var u0 = float(i) / segments
		var u1 = float(i + 1) / segments
		for j in rings:
			var v0 = float(j) / rings
			var v1 = float(j + 1) / rings
			# Clockwise winding seen from +Z: TL, TR, BR / TL, BR, BL
			vert.call(u0, v0); vert.call(u1, v0); vert.call(u1, v1)
			vert.call(u0, v0); vert.call(u1, v1); vert.call(u0, v1)
	return st.commit()

## Panel of [param size] (arc length x height) bent around a vertical cylinder
## of [param radius]. Concave bends the sides towards the viewer (+Z).
func _curved_mesh(size: Vector2, radius: float, concave: bool, segments := 24) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var bend = 1.0 if concave else -1.0
	var vert = func(u: float, v: float):
		var angle = (u - 0.5) * size.x / radius
		st.set_normal(Vector3(-sin(angle) * bend, 0, cos(angle)))
		st.set_uv(Vector2(u, v))
		st.add_vertex(Vector3(sin(angle) * radius, (0.5 - v) * size.y, bend * radius * (1.0 - cos(angle))))
	for i in segments:
		var u0 = float(i) / segments
		var u1 = float(i + 1) / segments
		# Clockwise winding seen from +Z: TL, TR, BR / TL, BR, BL
		vert.call(u0, 0.0); vert.call(u1, 0.0); vert.call(u1, 1.0)
		vert.call(u0, 0.0); vert.call(u1, 1.0); vert.call(u0, 1.0)
	return st.commit()

## Centres the Container3D children of [param row] horizontally.
func _layout_row(row: Node3D, gap: float):
	var total = 0.0
	for c in row.get_children(): total += c.size.x
	total += gap * (row.get_child_count() - 1)
	var x = -total / 2.0
	for c in row.get_children():
		c.position.x = x + c.size.x / 2.0
		x += c.size.x + gap
