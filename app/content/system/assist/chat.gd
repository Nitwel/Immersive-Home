@tool
extends Node3D

const FontTools = preload ("res://lib/utils/font_tools.gd")

@onready var label: Label3D = $Label3D
@onready var chat: Skeleton3D = $chat_bubble/Armature/Skeleton3D
@onready var model: MeshInstance3D = $chat_bubble/Armature/Skeleton3D/Cube

@export var text := "Hello, World!":
	set(value):
		if !is_node_ready(): await ready

		text = value
		label.text = value
		update()

@export var flip: bool = false:
	set(value):
		if !is_node_ready(): await ready

		flip = value
		model.rotation_degrees.x = -90 if value else 90

const base_width = 0.8 * 0.2

func update():
	var text_width = FontTools.get_font_size(label).x

	var offset = (text_width - base_width) / 0.2

	offset = max(0.0, offset)

	if flip:
		offset = -offset
	
	chat.set_bone_pose_position(1 if flip else 0, Vector3(0, offset, 0))