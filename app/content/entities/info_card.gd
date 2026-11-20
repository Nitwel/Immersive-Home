extends Entity
## Base of the display-only entity widgets (sun, zone, event, update, calendar, ...):
## a header with icon and name, a big value and a wrapping detail text. The card
## grows with the text. Subclasses fill the labels in _show() and can add rows
## below the detail text with _build() and _layout_extra().

const Entity = preload ("entity.gd")
const UI = preload ("entity_ui.gd")

## Card width; set it in _init() of a subclass.
var card_width := 0.22
## Top edge of the card; rows are stacked downwards from here.
const TOP = 0.0

var panel: Panel3D
var header_icon: Label3D
var name_label: Label3D
var value_label: Label3D
var detail_label: Label3D

var state := "unknown"
## Space the name may take up; subclasses with something on the right make it smaller.
var name_width := 0.0

func _ready():
	super()

	panel = UI.card(self, Vector2(card_width, 0.1))
	header_icon = UI.label(self, icon.value, 22, Vector3(-card_width / 2 + 0.02, TOP - 0.02, 0), HORIZONTAL_ALIGNMENT_CENTER, true)
	name_label = UI.label(self, entity_id, 22, Vector3(-card_width / 2 + 0.034, TOP - 0.02, 0))
	value_label = UI.label(self, "", 30, Vector3.ZERO, HORIZONTAL_ALIGNMENT_CENTER)
	detail_label = UI.label(self, "", 16, Vector3.ZERO, HORIZONTAL_ALIGNMENT_CENTER)
	detail_label.modulate = Color(1, 1, 1, 0.75)
	UI.wrap(detail_label, card_width - 0.024)
	if name_width == 0.0:
		name_width = card_width - 0.046

	_build()

	set_state(await HomeApi.get_state(entity_id))

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

func set_state(state_info):
	if state_info == null:
		return

	state = str(state_info["state"])
	var attributes = UI.attributes_of(state_info)

	UI.fit_label(name_label, UI.entity_name(entity_id, attributes), name_width)
	_show(state, attributes)
	header_icon.text = icon.value
	_layout()

## Fills icon.value, value_label and detail_label from the state.
func _show(_state: String, _attributes: Dictionary):
	pass

## Called once the labels exist, before the first state arrives.
func _build():
	pass

## Places extra rows starting at [param y] (top edge) and returns the new bottom.
func _layout_extra(y: float) -> float:
	return y

func _layout():
	var y = TOP - 0.04

	value_label.visible = value_label.text != ""
	if value_label.visible:
		_fit_value()
		var height = value_label.font_size * 0.0013
		value_label.position = Vector3(0, y - height / 2, 0)
		y -= height

	detail_label.visible = detail_label.text != ""
	if detail_label.visible:
		var height = _text_height(detail_label)
		detail_label.position = Vector3(0, y - height / 2 - 0.002, 0)
		y -= height + 0.004

	y = _layout_extra(y)

	var card_height = TOP - y + 0.01
	UI.resize_card(self, panel, Vector2(card_width, card_height), TOP - card_height / 2)

const VALUE_FONT_SIZE = 30
const VALUE_MIN_FONT_SIZE = 20

## Shrinks the value font until it fits the card, then shortens it with an ellipsis.
func _fit_value():
	var max_width = card_width - 0.02
	var size = VALUE_FONT_SIZE
	while size > VALUE_MIN_FONT_SIZE and UI.DeviceUtils.text_width(value_label.text, size, UI.DefaultFont) > max_width:
		size -= 2
	value_label.font_size = size
	UI.fit_label(value_label, value_label.text, max_width)

static func _text_height(node: Label3D) -> float:
	var font = node.font if node.font != null else UI.DefaultFont
	var size = font.get_multiline_string_size(node.text, node.horizontal_alignment, node.width if node.autowrap_mode != TextServer.AUTOWRAP_OFF else -1.0,
		node.font_size, -1, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
	return size.y * node.pixel_size
