extends RefCounted
## Shared layout of the Room setup views (overview, rooms, doors): the floor plan
## on a card on the left, a title, hint and the controls in a column on the right.
## Positions are in the menu content's space: x 0 .. 0.42, y 0 .. -0.32, with the
## view tabs along the top.

const UI = preload ("res://content/entities/entity_ui.gd")
const RoomsMap = preload ("./rooms_map.gd")

const CARD_CENTER = Vector3(0.125, -0.19, 0)
const CARD_SIZE = 0.225
const PLAN_SIZE = 0.19
const COLUMN_X = 0.255
const COLUMN_WIDTH = 0.15
const TITLE_Y = -0.09
const BUTTON = 0.035

## The floor plan on its card, in [param mode] (RoomsMap.Mode).
static func plan(parent: Node3D, mode: int) -> RoomsMap:
	var card = UI.glass(parent, Vector2(CARD_SIZE, CARD_SIZE))
	card.position = CARD_CENTER
	var node = RoomsMap.new()
	node.size = PLAN_SIZE
	node.mode = mode
	node.position = CARD_CENTER + Vector3(0, 0, 0.002)
	parent.add_child(node)
	return node

## Title of the right column, with an optional colour swatch before it (hidden
## until given a colour, see [method set_title]).
static func title(parent: Node3D, text: String) -> Label3D:
	var label = UI.label(parent, text, 16, Vector3(COLUMN_X, TITLE_Y, 0))
	var swatch = MeshInstance3D.new()
	swatch.mesh = QuadMesh.new()
	swatch.mesh.size = Vector2(0.011, 0.011)
	swatch.material_override = RoomsMap._material(Color.WHITE)
	swatch.position = Vector3(COLUMN_X + 0.0055, TITLE_Y, 0.001)
	swatch.visible = false
	parent.add_child(swatch)
	label.set_meta("swatch", swatch)
	return label

## Sets the title's text, cut to the column, with a swatch of [param color] (null:
## none).
static func set_title(label: Label3D, text: String, color = null):
	var swatch: MeshInstance3D = label.get_meta("swatch")
	swatch.visible = color != null
	if color != null:
		swatch.material_override.albedo_color = color
	var indent = 0.017 if color != null else 0.0
	label.position.x = COLUMN_X + indent
	UI.fit_label(label, text, COLUMN_WIDTH - indent)

## A small, dimmed text below the title that wraps within the column.
static func hint(parent: Node3D, text: String, y := TITLE_Y - 0.016) -> Label3D:
	var label = UI.label(parent, text, 11, Vector3(COLUMN_X, y, 0))
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	label.modulate = Color(1, 1, 1, 0.8)
	UI.wrap(label, COLUMN_WIDTH)
	return label

## An icon button at the column's left (or [param x]) with [param caption] next to it.
static func action(parent: Node3D, icon_name: String, caption: String, y: float, x := COLUMN_X) -> Button3D:
	var button = UI.icon_button(parent, icon_name, Vector3(x + BUTTON / 2.0, y, 0), BUTTON)
	var label = UI.label(parent, caption, 13, Vector3(x + BUTTON + 0.008, y, 0))
	button.set_meta("caption", label)
	return button

## Shows or hides an [method action] button with its caption.
static func show_action(button: Button3D, shown: bool):
	UI.set_shown(button, shown)
	button.disabled = not shown
	button.get_meta("caption").visible = shown

static func set_caption(button: Button3D, text: String):
	button.get_meta("caption").text = text
