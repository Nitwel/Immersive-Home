extends Node3D

@onready var button_1 = $JulianButton1
@onready var button_2 = $JulianButton2

@onready var browserobject = get_node_or_null("/root/Main/MediaBrowserObjects")

func _ready():
	button_1.on_button_down.connect(button_1_pressed)
	button_2.on_button_down.connect(button_2_pressed)

func button_1_pressed():
	var globalplacement = Transform3D(global_transform.basis, global_transform.origin + Vector3(0,-0.5,0) - global_transform.basis.z*0.2) 
	browserobject.playvideo("hgtake", globalplacement)

func button_2_pressed():
	var globalplacement = Transform3D(global_transform.basis, global_transform.origin + Vector3(0,0.5,0) - global_transform.basis.z*0.2) 
	browserobject.playvideo("zemarmot", globalplacement)
