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
