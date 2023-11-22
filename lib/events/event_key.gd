extends EventWithModifiers
class_name EventKey

var key: Key
var echo: bool

static func key_to_string(key: Key, caps: bool = false) -> String:
	match key: 
		KEY_ASCIITILDE: return "~"
		KEY_SLASH: return "/"
		KEY_BACKSLASH: return "\\"
		KEY_COLON: return ";"
		KEY_COMMA: return ","
		KEY_PERIOD: return "."
		KEY_MINUS: return "-"
		_: return OS.get_keycode_string(key).to_upper() if caps else OS.get_keycode_string(key).to_lower()