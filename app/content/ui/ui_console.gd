extends StaticBody3D

@onready var label = $Label3D

var max_message = 30
var messages: Array = ["aaa", "bbb"]

func log(text: Variant) -> void:
	messages.append(str(text))

	if messages.size() > max_message:
		messages.pop_front()

	label.text = "\n".join(messages)
