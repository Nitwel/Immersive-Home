@tool
extends Container3D
class_name Input3D

var text_handler = preload ("res://content/ui/components/input/text_handler.gd").new()

signal on_text_changed(text: String)

@onready var caret: MeshInstance3D = $Body/Label/Caret
@onready var panel: Panel3D = $Body/Panel3D
@onready var body: StaticBody3D = $Body
@onready var collision: CollisionShape3D = $Body/Collision
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var label: Label3D = $Body/Label
@onready var placeholder_label: Label3D = $Body/Placeholder
@onready var snap_sound = $SnapSound

@export var placeholder: String = "":
	set(value):
		placeholder = value
		if !is_inside_tree(): return

		placeholder_label.text = placeholder
	
@export var text: String = "":
	set(value):
		text = value
		if !is_inside_tree(): return

		var focused = Engine.is_editor_hint() == false&&EventSystem.is_focused(self) == false
		text_handler.set_text(text, focused)
		label.text = text_handler.get_display_text()
		_update_selection_highlight()
		_update_placeholder()

@export var disabled: bool = false:
	set(value):
		disabled = value
		if !is_inside_tree(): return
			
		if disabled:
			label.modulate = Color(0.7, 0.7, 0.7)
			add_to_group("ui_focus_skip")
			animation.stop()
			caret.visible = false
		else:
			label.modulate = Color(1, 1, 1)
			remove_from_group("ui_focus_skip")

var keyboard_input: bool = false

var input_plane = Plane(Vector3.UP, Vector3.ZERO)

func _ready():
	text_handler.label = label

	Update.props(self, ["text", "disabled", "width", "placeholder"])
	_update()

	if Engine.is_editor_hint():
		return

	_create_selection_highlight()

	EventSystem.on_key_down.connect(func(event):
		if EventSystem.is_focused(self) == false||disabled:
			return

		_handle_key(event.key, event.shift_pressed)
	)

## Applies a key press at the caret. With text selected, backspace deletes the
## selection and any other key replaces it.
func _handle_key(key: Key, shift: bool):
	var before = text.substr(0, text_handler.caret_position)
	var after = text.substr(text_handler.caret_position)

	if text_handler.has_selection():
		before = text.substr(0, text_handler.selection_start)
		after = text.substr(text_handler.selection_end)

		if key != KEY_BACKSPACE:
			var typed = EventKey.key_to_string(key, shift, before)
			if typed == before:
				return # key doesn't produce text (e.g. caps lock); keep the selection
			before = typed
	else:
		before = EventKey.key_to_string(key, shift, before)

	_apply_edit(before + after, before.length())

## Inserts [param value] at the caret (replacing any selection), as if it had been typed.
func insert_text(value: String):
	if disabled:
		return

	var start = text_handler.caret_position
	var end = text_handler.caret_position
	if text_handler.has_selection():
		start = text_handler.selection_start
		end = text_handler.selection_end

	_apply_edit(text.substr(0, start) + value + text.substr(end), start + value.length())

func _apply_edit(new_text: String, new_caret: int):
	if new_text == text:
		return

	text = new_text # setter updates the text handler and clears the selection
	text_handler.caret_position = new_caret
	text_handler.focus_caret()
	_refresh_text()
	on_text_changed.emit(text)

## Syncs the label, caret and selection highlight with the text handler.
func _refresh_text():
	label.text = text_handler.get_display_text()
	caret.position.x = text_handler.get_caret_position()
	_update_selection_highlight()

# --- Selection --------------------------------------------------------------

const MULTI_CLICK_TIME = 400 # ms between presses to count as a double/triple click
const SELECTION_COLOR = Color(0.95, 0.4, 0.25, 0.35)

var _selection_highlight: MeshInstance3D
var _last_press_time := -MULTI_CLICK_TIME
var _click_count := 0

func _create_selection_highlight():
	_selection_highlight = MeshInstance3D.new()
	_selection_highlight.name = "SelectionHighlight"
	_selection_highlight.mesh = QuadMesh.new()

	var material = StandardMaterial3D.new()
	material.albedo_color = SELECTION_COLOR
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_selection_highlight.material_override = material
	_selection_highlight.visible = false
	label.add_child(_selection_highlight)

func _update_selection_highlight():
	if _selection_highlight == null:
		return

	var rect = text_handler.get_selection_rect()
	if rect.is_empty() or not label.visible:
		_selection_highlight.visible = false
		return

	_selection_highlight.visible = true
	_selection_highlight.mesh.size = Vector2(rect[1] - rect[0], caret.mesh.size.y * 1.1)
	# Slightly in front of the text; the highlight is translucent so the text stays readable.
	_selection_highlight.position = Vector3((rect[0] + rect[1]) / 2.0, 0, 0.0002)

## Counts presses in quick succession: 2 selects a word, 3 selects everything.
func _handle_multi_click():
	var now = Time.get_ticks_msec()
	_click_count = _click_count + 1 if now - _last_press_time <= MULTI_CLICK_TIME else 1
	_last_press_time = now

	match _click_count:
		2: text_handler.select_word_at(text_handler.caret_position)
		3: text_handler.select_all()

func _input(event):
	if event is InputEventKey&&EventSystem.is_focused(self)&&event.pressed:
		if event.keycode == KEY_F1:
			keyboard_input = !keyboard_input
			return

		if disabled:
			return

		if keyboard_input:
			_handle_key(event.keycode, event.shift_pressed)
		
func _process(_delta):
	if Engine.is_editor_hint():
		return

	if get_tree().debug_collisions_hint:
		_draw_debug_text_gaps()
	
func _on_press_down(event):
	if disabled:
		return

	var pos_x = label.to_local(event.ray.get_collision_point()).x
	text_handler.update_caret_position(pos_x)
	_handle_multi_click()
	_refresh_text()

func _on_press_move(event):
	if disabled:
		return

	var ray_pos = event.ray.global_position
	var ray_dir = -event.ray.global_transform.basis.z

	var local_pos = label.to_local(ray_pos)
	var local_dir = label.global_transform.basis.inverse() * ray_dir

	var intersection_point = input_plane.intersects_ray(local_pos, local_dir)

	if intersection_point == null:
			return

	var pos_x = intersection_point.x
	text_handler.update_caret_position(pos_x)
	_refresh_text()

func _on_ray_enter(_event: EventPointer):
	if disabled:
		return

	panel.hovering = true

func _on_ray_leave(_event: EventPointer):
	panel.hovering = false

func _on_focus_in(_event):
	if disabled:
		return

	caret.position.x = text_handler.get_caret_position()
	label.text = text_handler.get_display_text()
	caret.visible = true
	panel.active = true
	animation.play("blink")
	snap_sound.play()
	_update_placeholder()

func update_caret_position(event):
	var ray_pos = event.ray.global_position
	var ray_dir = -event.ray.global_transform.basis.z

	var local_pos = label.to_local(ray_pos)
	var local_dir = label.global_transform.basis.inverse() * ray_dir

	var intersection_point = input_plane.intersects_ray(local_pos, local_dir)

	if intersection_point == null:
			return

	var pos_x = intersection_point.x
	text_handler.update_caret_position(pos_x)

	caret.position.x = text_handler.get_caret_position()

func _on_focus_out(_event):
	if disabled:
		return

	animation.stop()
	caret.visible = false
	panel.active = false
	text_handler.clear_selection()
	_update_selection_highlight()
	_update_placeholder()

func _draw_debug_text_gaps():
	if text_handler.gap_offsets == null:
		return

	for i in range(text_handler.gap_offsets.size()):
		var offset = text_handler.gap_offsets[i] - text_handler.gap_offsets[text_handler.char_offset]
		DebugDraw3D.draw_line(
			label.to_global(Vector3(offset, -0.01, 0)),
			label.to_global(Vector3(offset, 0.01, 0)),
			Color(1, 0, 0) if i != text_handler.overflow_index else Color(0, 1, 0)
		)

func _update_placeholder():
	var show_placeholder = text == ""&&panel.active == false

	placeholder_label.visible = show_placeholder
	label.visible = !show_placeholder

const TEXT_PADDING = 0.002

func _update():
	text_handler.width = size.x - TEXT_PADDING * 2
	panel.size = Vector2(size.x, size.y)
	panel.position.z = size.z / 2
	collision.shape.size = size
	label.position = Vector3( - size.x / 2 + TEXT_PADDING, 0, size.z / 2)
	label.text = text_handler.get_display_text()
	placeholder_label.position = label.position
	body.position = Vector3(0, 0, size.z / 2)