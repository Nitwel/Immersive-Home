@tool
extends Node3D

const FontTools = preload ("res://lib/utils/font_tools.gd")

@onready var label: Label3D = $Label3D
@onready var chat: Skeleton3D = $chat_bubble/Armature/Skeleton3D
@onready var chat_flipped: Skeleton3D = $"chat_bubble-flipped/Armature/Skeleton3D"
@onready var model: Node3D = $chat_bubble
@onready var model_flipped: Node3D = $"chat_bubble-flipped"

@export var text := "Hello, World!":
	set(value):
		text = value
		if !is_node_ready(): await ready

		label.text = value
		update()

@export var flip: bool = false:
	set(value):
		flip = value
		if !is_node_ready(): await ready

		model.visible = !value
		model_flipped.visible = value

const base_width = 0.8 * 0.2

func update():
	var text_width = FontTools.get_font_size(label).x

	var offset = (text_width - base_width) / 0.2

	offset = max(0.0, offset)
	
	chat.set_bone_pose_position(0, Vector3(0, offset, 0))
	chat_flipped.set_bone_pose_position(1, Vector3(0, -offset, 0))