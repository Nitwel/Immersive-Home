extends Node3D

const button_scene = preload("res://content/ui/components/button/button.tscn")

@onready var keys = $Keys
@onready var caps_button = $Caps
var key_list = [
	["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "~"],
	["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "/"],
	["A", "S", "D", "F", "G", "H", "J", "K", "L", ":", "\\"],
	["Z", "X", "C", "V", "B", "N", "M", ",", ".", "-"]
]

var caps = false

func _ready():
	for row in key_list:
		for key in row:
			print(key)
			var button = create_key(key)
			keys.add_child(button)

	keys.columns = key_list[0].size()

func _on_click(event):
	if event.target == caps_button:
		caps = event.active
		return

	var code = event.target.get_children()[event.target.get_child_count() - 1].text

	if caps:
		code = code.to_upper()
	else:
		code = code.to_lower()

	Events.typed.emit(code)
	print(code)

func create_key(key: String):
	var button = button_scene.instantiate()

	var label = Label3D.new()
	label.text = key
	label.pixel_size = 0.001
	label.position = Vector3(0, 0.012, 0)
	label.rotate_x(deg_to_rad(-90))

	button.add_child(label)

	return button
