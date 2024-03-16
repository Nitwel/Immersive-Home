@tool
extends StaticBody3D

const button_scene = preload ("res://content/ui/components/button/button.tscn")

@onready var keys = $Keys
@onready var caps_button = $Caps
@onready var backspace_button = $Backspace
@onready var paste_button = $Paste
var key_list = [
	[KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0, KEY_ASCIITILDE],
	[KEY_Q, KEY_W, KEY_E, KEY_R, KEY_T, KEY_Y, KEY_U, KEY_I, KEY_O, KEY_P, KEY_SLASH],
	[KEY_A, KEY_S, KEY_D, KEY_F, KEY_G, KEY_H, KEY_J, KEY_K, KEY_L, KEY_COLON, KEY_BACKSLASH],
	[KEY_Z, KEY_X, KEY_C, KEY_V, KEY_B, KEY_N, KEY_M, KEY_COMMA, KEY_PERIOD, KEY_MINUS]
]

var caps = false:
	set(value):
		caps = value
		update_labels()

func _ready():
	for row in key_list:
		for key in row:
			var key_node = create_key(key)
			keys.add_child(key_node)

			if Engine.is_editor_hint():
				continue

			key_node.on_button_down.connect(func():
				_emit_event("key_down", key)
			)
			key_node.on_button_up.connect(func():
				_emit_event("key_up", key)
			)

	keys.columns = key_list[0].size()

	if Engine.is_editor_hint():
		return

	backspace_button.on_button_down.connect(func():
		_emit_event("key_down", KEY_BACKSPACE)
	)

	backspace_button.on_button_up.connect(func():
		_emit_event("key_up", KEY_BACKSPACE)
	)

	caps_button.on_button_down.connect(func():
		caps=true
		_emit_event("key_down", KEY_CAPSLOCK)
	)

	caps_button.on_button_up.connect(func():
		caps=false
		_emit_event("key_up", KEY_CAPSLOCK)
	)

	paste_button.on_button_down.connect(func():
		# There is no KEY_PASTE obviously, so we use KEY_INSERT for now
		_emit_event("key_down", KEY_INSERT)
	)

	paste_button.on_button_up.connect(func():
		_emit_event("key_up", KEY_INSERT)
	)

func create_key(key: Key):
	var key_node = button_scene.instantiate()
	
	key_node.label = EventKey.key_to_string(key, caps)
	key_node.focusable = false
	key_node.font_size = 32
	key_node.echo = true
	key_node.set_meta("key", key)

	return key_node

func update_labels():
	for key_button in keys.get_children():
		if caps:
			key_button.label = key_button.label.to_upper()
		else:
			key_button.label = key_button.label.to_lower()

func _emit_event(type: String, key: Key):
	var event = EventKey.new()
	event.key = key
	event.shift_pressed = caps
	
	EventSystem.emit(type, event)
