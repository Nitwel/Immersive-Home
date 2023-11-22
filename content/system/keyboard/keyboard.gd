@tool
extends StaticBody3D

const button_scene = preload("res://content/ui/components/button/button.tscn")

@onready var keys = $Keys
@onready var caps_button = $Caps
@onready var backspace_button = $Backspace
var key_list = [
	[KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0, KEY_ASCIITILDE],
	[KEY_Q, KEY_W, KEY_E, KEY_R, KEY_T, KEY_Y, KEY_U, KEY_I, KEY_O, KEY_P, KEY_SLASH],
	[KEY_A, KEY_S, KEY_D, KEY_F, KEY_G, KEY_H, KEY_J, KEY_K, KEY_L, KEY_COLON, KEY_BACKSLASH],
	[KEY_Z, KEY_X, KEY_C, KEY_V, KEY_B, KEY_N, KEY_M, KEY_COMMA , KEY_PERIOD, KEY_MINUS]
]

var caps = false :
	set(value):
		caps = value
		update_labels()

func _ready():
	for row in key_list:
		for key in row:
			var button = create_key(key)
			keys.add_child(button)

			button.on_button_down.connect(func():
				_emit_event("key_down", key)
			)
			button.on_button_up.connect(func():
				_emit_event("key_up", key)
			)

	keys.columns = key_list[0].size()

	backspace_button.on_button_down.connect(func():
		_emit_event("key_down", KEY_BACKSPACE)
	)

	backspace_button.on_button_up.connect(func():
		_emit_event("key_up", KEY_BACKSPACE)
	)

	caps_button.on_button_down.connect(func():
		caps = true
		_emit_event("key_down", KEY_CAPSLOCK)
	)

	caps_button.on_button_up.connect(func():
		caps = false
		_emit_event("key_up", KEY_CAPSLOCK)
	)

func create_key(key: Key):
	var button = button_scene.instantiate()

	var label = Label3D.new()
	label.text = EventKey.key_to_string(key, caps)
	label.pixel_size = 0.001
	label.position = Vector3(0, 0.012, 0)
	label.rotate_x(deg_to_rad(-90))
	label.add_to_group("button_label")
	
	button.set_meta("key", key)

	button.add_child(label)

	return button

func update_labels():
	for key_button in keys.get_children():
		var label = key_button.get_children()[key_button.get_children().size() - 1]
		if caps:
			label.text = label.text.to_upper()
		else:
			label.text = label.text.to_lower()

func _emit_event(type: String, key: Key):
	var event = EventKey.new()
	event.key = key
	event.shift_pressed = caps
	
	EventSystem.emit(type, event)
	print("Emitting event: " + type + " " + EventKey.key_to_string(key, caps))

