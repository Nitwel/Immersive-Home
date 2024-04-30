extends Node

const console_scene = preload ("res://content/ui/console.tscn")
@onready var main = $"/root/Main"
@onready var console = $"/root/Main/Console"

func _ready():
	await main.ready

	main.remove_child(console)

func log(message):
	print(message)
	if console.get_parent() == null:
		main.add_child(console)

	console.log(message)
