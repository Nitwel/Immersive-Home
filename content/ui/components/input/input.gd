@tool
extends StaticBody3D

@onready var label: Label3D = $Label
@export var text: String = "Hello World":
	set(value):
		var old_text = text
		text = value
		if label == null:
			return
		
		label.text = value
		if Engine.is_editor_hint():
			return
		gap_offsets = _calculate_text_gaps()
		caret_position += text.length() - old_text.length()
		text_changed.emit(value)

@onready var caret: MeshInstance3D = $Label/Caret

@onready var animation: AnimationPlayer = $AnimationPlayer

signal text_changed(text: String)

var keyboard_input: bool = false
var gap_offsets = []
var caret_position: int = 3:
	set(value):
		caret_position = clampi(value, 0, text.length())
		caret.position.x = gap_offsets[caret_position]

func _ready():
	text = text # So @tool works

	if Engine.is_editor_hint():
		return

	EventSystem.on_key_down.connect(func(event):
		if EventSystem.is_focused(self) == false:
			return

		text = EventKey.key_to_string(event.key, event.shift_pressed, text.substr(0, caret_position)) + text.substr(caret_position, text.length())
	)

func _input(event):
	if event is InputEventKey && EventSystem.is_focused(self) && event.pressed:
		if event.keycode == KEY_F1:
			keyboard_input = !keyboard_input
			return

		if keyboard_input:
			text = EventKey.key_to_string(event.keycode, event.shift_pressed, text.substr(0, caret_position)) + text.substr(caret_position, text.length())
		
func _process(_delta):
	if Engine.is_editor_hint():
		return

	if get_tree().debug_collisions_hint && OS.get_name() != "Android":
		_draw_debug_text_gaps()

func _calculate_caret_pos(click_pos_x: float):
	for i in range(1, gap_offsets.size()):
		var left = gap_offsets[i]
		
		if click_pos_x < left:
			return i - 1

	return gap_offsets.size() - 1
	

func _on_focus_in(event):
	gap_offsets = _calculate_text_gaps()

	var pos_x = label.to_local(event.ray.get_collision_point()).x

	caret_position = _calculate_caret_pos(pos_x)
	animation.play("blink")

func _on_focus_out(_event):
	animation.stop()
	caret.hide()

func _calculate_text_gaps():
	var font = label.get_font()
	var offsets = [0.0]

	var offset = 0.0
	for i in range(text.length()):
		var character = text[i]
		var size = font.get_string_size(character, HORIZONTAL_ALIGNMENT_CENTER, -1, label.font_size)

		offset += size.x * label.pixel_size
		offsets.append(offset)
	
	return offsets

func _draw_debug_text_gaps():
	for offset in gap_offsets:
		DebugDraw3D.draw_line(
			label.to_global(Vector3(offset, -0.01, 0)),
			label.to_global(Vector3(offset, 0.01, 0)),
			Color(1, 0, 0),
		)
