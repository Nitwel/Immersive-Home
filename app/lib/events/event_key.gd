extends EventWithModifiers
## Events emitted by the Virtual Keyboard
class_name EventKey

## The key that was pressed or released
var key: Key
## true if the event is repeated due to a key being held down for a while
var echo: bool

## Modifies a string based on the key pressed.
## Printable keys use their ASCII keycode (e.g. [constant KEY_EXCLAM] for "!"),
## letters are upper case when [param caps] is true. Other keys don't produce text.
static func key_to_string(key: Key, caps: bool=false, apply_to: String="") -> String:
	match key:
		KEY_INSERT: return apply_to + DisplayServer.clipboard_get()
		KEY_BACKSPACE: return apply_to.substr(0, apply_to.length() - 1)

	if key >= KEY_SPACE and key <= KEY_ASCIITILDE:
		var character = char(key)
		return apply_to + (character.to_upper() if caps else character.to_lower())

	return apply_to
