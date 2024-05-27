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
		if !is_inside_tree(): return
		
		label.text = text
		var text_width = FontTools.get_label_size(label).x

		var offset = (text_width - base_width) / 0.2

		offset = max(0.0, offset)
		
		chat.set_bone_pose_position(0, Vector3(0, offset, 0))
		chat_flipped.set_bone_pose_position(1, Vector3(0, -offset, 0))

@export var flip: bool = false:
	set(value):
		flip = value
		if !is_inside_tree(): return
		
		model.visible = !flip
		model_flipped.visible = flip

const base_width = 0.8 * 0.2

func _ready():
	Update.props(self, ["text", "flip"])
