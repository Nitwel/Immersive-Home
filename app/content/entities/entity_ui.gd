extends RefCounted
## Builders for the glass-card look shared by the code-built entities
## (select, climate, lock, text, date/time). Matches the timer entity's styling.

const PanelScene = preload ("res://content/ui/components/panel/panel.tscn")
const ButtonScene = preload ("res://content/ui/components/button/button.tscn")
const SelectScene = preload ("res://content/ui/components/select/select.tscn")
const InputScene = preload ("res://content/ui/components/input/input.tscn")
const IconFont = preload ("res://assets/icons/icons.tres")

## Glass card of [param size] centred on the parent; also sizes the entity's collision
## shape so the whole card can be grabbed and moved.
static func card(entity: Node3D, size: Vector2) -> Panel3D:
	var panel = glass(entity, size)

	var collision: CollisionShape3D = entity.get_node("CollisionShape3D")
	var shape = BoxShape3D.new()
	shape.size = Vector3(size.x, size.y, 0.02)
	collision.shape = shape
	collision.position = Vector3(0, 0, -0.01)
	return panel

## Glass panel of [param size] centred on [param parent], e.g. for a settings panel.
static func glass(parent: Node3D, size: Vector2) -> Panel3D:
	var panel: Panel3D = PanelScene.instantiate()
	panel.size = size
	panel.corner_radius = 0.012
	parent.add_child(panel)
	return panel

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

## Attributes of a state dictionary, never null.
static func attributes_of(state_info) -> Dictionary:
	if state_info == null:
		return {}
	var attributes = state_info.get("attributes", {})
	return attributes if attributes is Dictionary else {}

static func is_unavailable(state: String) -> bool:
	return state == "unavailable"||state == "unknown"
