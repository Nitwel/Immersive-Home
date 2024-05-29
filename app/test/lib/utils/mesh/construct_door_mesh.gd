@tool
extends Node3D

const ConstructDoorMesh = preload ("res://lib/utils/mesh/construct_door_mesh.gd")

@onready var door_mesh = $DoorMesh
@onready var door_mesh_grid = $DoorMeshGrid
@onready var room1_pos1 = $Room1Pos1
@onready var room1_pos2 = $Room1Pos2
@onready var room2_pos1 = $Room2Pos1
@onready var room2_pos2 = $Room2Pos2

func _ready():
	door_mesh.mesh = ConstructDoorMesh.generate_door_mesh(room1_pos1.position, room2_pos1.position, room2_pos2.position, room1_pos2.position)
	door_mesh_grid.mesh = ConstructDoorMesh.generate_door_mesh_grid(room1_pos1.position, room2_pos1.position, room2_pos2.position, room1_pos2.position)