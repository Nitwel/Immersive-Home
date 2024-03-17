extends StaticBody3D

@onready var label = $Label3D

var max_message = 30
var messages: Array = ["aaa", "bbb"]

func log(text: Variant) -> void:
	messages.push_front(str(text))

	if messages.size() > max_message:
		messages.pop_back()

func _process(_delta: float) -> void:

	label.text = "\n".join(messages)
