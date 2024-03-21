extends Node

const console_scene = preload ("res://content/ui/console.tscn")
var _console: Node3D = null

func _ready():
	get_node("/root/Main").tree_entered.connect(func():
		init_console()
	)

func init_console():
	_console = console_scene.instantiate()
	get_node("/root/Main").add_child(_console)
	var camera = get_node("/root/Main/XROrigin3D/XRCamera3D")

	_console.global_position = camera.global_position + camera.global_transform.basis.z * - 1
	_console.global_transform.basis = Basis.looking_at(_console.global_position - camera.global_position)

func log(message):
	print(message, _console)
	if _console == null:
		init_console()

	_console.log(message)
