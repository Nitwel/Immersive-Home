@tool
extends Node3D

const CornerScene = preload ("./corner.tscn")
const EdgeScene = preload ("./edge.tscn")

var edges = []
var corners = []
var grabbing = null

@export var size = Vector3(1, 1, 1):
	set(value):
		size = value

		if is_node_ready() == false:
			return

		update_nodes()

func _ready():
	generate_nodes()
	update_nodes()

func opposite_corner(corner):
	return corners[7 - corners.find(corner)]

func generate_nodes():
	for i in range(8):
		var corner = CornerScene.instantiate()
		add_child(corner)
		corners.append(corner)

		corner.get_node("Movable").on_move.connect(func(position, rotation):
			var opposite=opposite_corner(corner)
			var new_center=lerp(corner.global_position, opposite.global_position, 0.5)

			global_position=new_center
			size=(opposite.position - corner.position).abs()
		)

	for i in range(12):
		var edge = EdgeScene.instantiate()
		add_child(edge)
		edges.append(edge)

func update_nodes():
	if corners.size() == 0:
		return

	for i in range(8):
		var corner = corners[i]
		corner.position = Vector3(
			(i&1) * size.x - size.x / 2,
			(i&2) / 2 * size.y - size.y / 2,
			(i&4) / 4 * size.z - size.z / 2
		)

	for i in range(3):
		for j in range(4):
			var edge = edges[i * 4 + j]
			var i1 = (i + 1) % 3
			var i2 = (i + 2) % 3

			edge.position = Vector3(
				- size.x / 2,
				- size.y / 2,
				- size.z / 2,
			)

			edge.position[i] = 0.0
			edge.position[i1] = (j&1) * size[i1] - size[i1] / 2
			edge.position[i2] = (j&2) / 2 * size[i2] - size[i2] / 2

			var dir = Vector3.ZERO
			dir[2 - i] = 1.0
			edge.mesh.height = size[i]

			edge.transform.basis = Basis().rotated(dir, PI / 2)