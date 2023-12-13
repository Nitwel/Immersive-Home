@tool
extends Node3D

@onready var label: Label3D = $AnimationNode/Text
@onready var icon_label: Label3D = $AnimationNode/Icon
@onready var mesh: MeshInstance3D = $AnimationNode/MeshInstance3D
@onready var collision: CollisionShape3D = $AnimationNode/CollisionShape3D
@onready var animation_player: AnimationPlayer = $AnimationNode/AnimationPlayer
@onready var button = $AnimationNode/Button
@onready var timer = $AnimationNode/Timer

@export var type: EventNotify.Type = EventNotify.Type.INFO:
	set(value):
		type = value
		if !is_node_ready(): await ready
		print(value, " ", _type_to_string(value))
		icon_label.text = _type_to_string(value)
@export var text: String = "":
	set(value):
		text = value
		if !is_node_ready(): await ready
		label.text = value

func _ready():
	button.on_button_down.connect(fade_out)
	fade_in()

	timer.timeout.connect(func():
		fade_out()
	)

func fade_in():
	if !is_node_ready(): await ready
	
	animation_player.play("fade_in")

func fade_out():
	animation_player.play_backwards("fade_in")

	await animation_player.animation_finished
	queue_free()

func _type_to_string(type: EventNotify.Type) -> String:
	match type:
		EventNotify.Type.INFO:
			return "info"
		EventNotify.Type.SUCCESS:
			return "check_circle"
		EventNotify.Type.WARNING:
			return "error"
		EventNotify.Type.DANGER:
			return "warning"
		_:
			return "info"
