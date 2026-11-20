@tool
extends StaticBody3D

const button_scene = preload("res://content/ui/components/button/button.tscn")

## Distance between the left edges of two neighbouring keys (one key unit).
const UNIT = 0.06
const GAP = 0.01
const KEY_DEPTH = 0.01
const CHAR_FONT_SIZE = 32
const ICON_FONT_SIZE = 30

const QR = "qr"

## US QWERTY layout. An entry is a key or [key, width in key units].
## Every row adds up to 15 units, like a real keyboard.
const LAYOUT = [
	[KEY_QUOTELEFT, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0, KEY_MINUS, KEY_EQUAL, [KEY_BACKSPACE, 2.0]],
	[[KEY_INSERT, 1.5], KEY_Q, KEY_W, KEY_E, KEY_R, KEY_T, KEY_Y, KEY_U, KEY_I, KEY_O, KEY_P, KEY_BRACKETLEFT, KEY_BRACKETRIGHT, [KEY_BACKSLASH, 1.5]],
	[[KEY_CAPSLOCK, 1.75], KEY_A, KEY_S, KEY_D, KEY_F, KEY_G, KEY_H, KEY_J, KEY_K, KEY_L, KEY_SEMICOLON, KEY_APOSTROPHE, [KEY_ENTER, 2.25]],
	[[KEY_SHIFT, 2.25], KEY_Z, KEY_X, KEY_C, KEY_V, KEY_B, KEY_N, KEY_M, KEY_COMMA, KEY_PERIOD, KEY_SLASH, [KEY_SHIFT, 2.75]],
	[[QR, 1.5], [KEY_SPACE, 11.0], [KEY_LEFT, 1.25], [KEY_RIGHT, 1.25]],
]
const ROW_UNITS = 15.0

## The character a key types while shift is held.
const SHIFTED = {
	KEY_QUOTELEFT: KEY_ASCIITILDE,
	KEY_1: KEY_EXCLAM,
	KEY_2: KEY_AT,
	KEY_3: KEY_NUMBERSIGN,
	KEY_4: KEY_DOLLAR,
	KEY_5: KEY_PERCENT,
	KEY_6: KEY_ASCIICIRCUM,
	KEY_7: KEY_AMPERSAND,
	KEY_8: KEY_ASTERISK,
	KEY_9: KEY_PARENLEFT,
	KEY_0: KEY_PARENRIGHT,
	KEY_MINUS: KEY_UNDERSCORE,
	KEY_EQUAL: KEY_PLUS,
	KEY_BRACKETLEFT: KEY_BRACELEFT,
	KEY_BRACKETRIGHT: KEY_BRACERIGHT,
	KEY_BACKSLASH: KEY_BAR,
	KEY_SEMICOLON: KEY_COLON,
	KEY_APOSTROPHE: KEY_QUOTEDBL,
	KEY_COMMA: KEY_LESS,
	KEY_PERIOD: KEY_GREATER,
	KEY_SLASH: KEY_QUESTION,
}

const ICONS = {
	KEY_BACKSPACE: "backspace",
	KEY_INSERT: "content_paste",
	KEY_CAPSLOCK: "shift_lock",
	KEY_ENTER: "keyboard_return",
	KEY_SHIFT: "shift",
	KEY_SPACE: "space_bar",
	KEY_LEFT: "keyboard_arrow_left",
	KEY_RIGHT: "keyboard_arrow_right",
	QR: "qr_code",
}

@onready var keys = $Keys

var caps_button: Button3D
var qr_button: Button3D
## The running QR scan was started from this keyboard.
var _qr_scan_started := false
var shift_buttons: Array[Button3D] = []
## Buttons that type a character, mapped to their unshifted key.
var char_buttons := {}
## The key each held character button emits, so key repeat and key up stay
## consistent after a one-shot shift is released.
var _held := {}
## Where the keyboard was in the tree before it got hidden.
var _parent: Node

var caps = false:
	set(value):
		caps = value
		_update_labels()

## One-shot shift: released again after the next character is typed.
var shift = false:
	set(value):
		if shift == value:
			return
		shift = value
		for button in shift_buttons:
			button.active = shift
		_update_labels()

func _ready():
	_create_keys()

	if Engine.is_editor_hint():
		return
	_parent = get_parent()
	_parent.remove_child.call_deferred(self)

	_prepare_keyboard_spawn()
	_connect_qr_scanner()

func _prepare_keyboard_spawn():
	if Engine.is_editor_hint():
		return

	EventSystem.on_focus_in.connect(func(event):
		if is_inside_tree():
			return

		if App.main == null:
			# Outside of the app (e.g. the UI gallery), show it where it was placed.
			_parent.add_child(self)
			return

		App.main.add_child(self)
		global_transform = App.menu.get_node("AnimationContainer/KeyboardPlace").global_transform
	)

	EventSystem.on_focus_out.connect(func(event):
		if !is_inside_tree():
			return

		_parent = get_parent()
		_parent.remove_child(self)
	)

func _create_keys():
	for row_index in LAYOUT.size():
		var x := 0.0

		for entry in LAYOUT[row_index]:
			var key = entry[0] if entry is Array else entry
			var width: float = entry[1] if entry is Array else 1.0

			var key_node = _create_key(key, width)
			key_node.position = Vector3(
				(x + width / 2 - ROW_UNITS / 2) * UNIT,
				(LAYOUT.size() / 2.0 - row_index - 0.5) * UNIT,
				0
			)
			keys.add_child(key_node)

			if ICONS.has(key):
				# Icons scale with the button width by default, keep them equal on wide keys.
				key_node.label_node.font_size = ICON_FONT_SIZE

			x += width

			if Engine.is_editor_hint():
				continue

			_connect_key(key_node, key)

	_update_labels()

func _create_key(key, width: float) -> Button3D:
	var key_node = button_scene.instantiate()

	key_node.size = Vector3(width * UNIT - GAP, UNIT - GAP, KEY_DEPTH)
	key_node.focusable = false

	if ICONS.has(key):
		key_node.label = ICONS[key]
		key_node.icon = true
	else:
		key_node.font_size = CHAR_FONT_SIZE

	match key:
		KEY_CAPSLOCK:
			key_node.toggleable = true
			caps_button = key_node
		KEY_SHIFT:
			key_node.toggleable = true
			shift_buttons.append(key_node)
		QR:
			key_node.toggleable = true
			qr_button = key_node
		KEY_INSERT, KEY_ENTER:
			pass # pasting or submitting repeatedly while held isn't useful
		_:
			key_node.echo = true

	if key is int and _is_char_key(key):
		char_buttons[key_node] = key

	return key_node

func _connect_key(key_node: Button3D, key):
	if key_node in char_buttons:
		key_node.on_button_down.connect(_on_char_down.bind(key_node))
		key_node.on_button_up.connect(_on_char_up.bind(key_node))
		return

	match key:
		QR:
			pass # see _connect_qr_scanner
		KEY_CAPSLOCK:
			key_node.on_toggled.connect(func(active):
				caps = active
				_emit_event("key_down" if active else "key_up", KEY_CAPSLOCK)
			)
		KEY_SHIFT:
			key_node.on_toggled.connect(func(active):
				shift = active
			)
		_:
			key_node.on_button_down.connect(func():
				_emit_event("key_down", key)
			)
			key_node.on_button_up.connect(func():
				_emit_event("key_up", key)
			)

func _on_char_down(key_node: Button3D):
	if not _held.has(key_node):
		var key = char_buttons[key_node]
		_held[key_node] = [SHIFTED.get(key, key) if shift else key, caps != shift]
		# Like a phone keyboard, shift only applies to the next character.
		shift = false

	_emit_event("key_down", _held[key_node][0], _held[key_node][1])

func _on_char_up(key_node: Button3D):
	var held = _held.get(key_node, [char_buttons[key_node], caps])
	_held.erase(key_node)
	_emit_event("key_up", held[0], held[1])

func _is_char_key(key: int) -> bool:
	return key > KEY_SPACE and key <= KEY_ASCIITILDE

func _connect_qr_scanner():
	qr_button.on_button_down.connect(_start_qr_scan)
	qr_button.on_button_up.connect(func(_event=null):
		_qr_scan_started=false
		QrScanner.stop()
	)

	QrScanner.on_scanning_changed.connect(func(scanning):
		qr_button.active = scanning
	)

	QrScanner.on_timeout.connect(func():
		# Other scans, e.g. the room alignment, report their own timeout.
		if not _qr_scan_started:
			return
		_qr_scan_started = false
		EventSystem.notify("No QR code found.", EventNotify.Type.WARNING)
	)

	QrScanner.on_scanned.connect(_on_qr_scanned)

	# The keyboard is taken out of the tree when the input loses focus.
	tree_exiting.connect(QrScanner.stop)

func _start_qr_scan():
	_qr_scan_started = true
	var error = await QrScanner.start()

	match error:
		QrScanner.ScanError.OK:
			EventSystem.notify("Look at a QR code to scan it.")
		QrScanner.ScanError.UNSUPPORTED:
			EventSystem.notify("QR code scanning isn't supported on this device. Meta Quest needs Horizon OS v83 or newer.", EventNotify.Type.WARNING)
		QrScanner.ScanError.PERMISSION_DENIED:
			EventSystem.notify("QR code scanning needs the spatial data permission.", EventNotify.Type.WARNING)

	if error != QrScanner.ScanError.OK:
		qr_button.active = false

func _on_qr_scanned(text: String):
	_qr_scan_started = false
	var focused = EventSystem.get_focused()

	if focused == null:
		return

	# Let the focused input or one of its parents handle the content first,
	# e.g. the API settings fill in URL and token at once.
	var event = EventQr.new()
	event.text = text
	event.target = focused

	EventSystem.emit("qr_scan", event)

	if event.bubbling && focused.has_method("insert_text"):
		focused.insert_text(text)

func _update_labels():
	for key_node in char_buttons:
		var key = char_buttons[key_node]
		if shift:
			key = SHIFTED.get(key, key)
		key_node.label = EventKey.key_to_string(key, caps != shift)

func _emit_event(type: String, key: Key, shift_pressed: bool = caps):
	var event = EventKey.new()
	event.key = key
	event.shift_pressed = shift_pressed

	EventSystem.emit(type, event)
