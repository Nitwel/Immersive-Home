@tool
extends Node3D

const CornerScene = preload ("./corner.tscn")
const EdgeScene = preload ("./edge.tscn")

@onready var area = $Area3D
@onready var area_collision = $Area3D/CollisionShape3D
@onready var mesh = $MeshInstance3D
@onready var collision = $CollisionShape3D
@onready var name_input = $Input

var edges = []
var corners = []
var grabbing = null
var id: int = 0

@export var size = Vector3(1, 1, 1):
	set(value):
		if size == value: return

		size = value

		if is_node_ready() == false:
			return

		update_area()
		if edit:
			update_nodes()

@export var edit: bool = false:
	set(value):
		if edit == value: return

		edit = value

		if is_node_ready() == false:
			return

		clear_nodes()
		if Engine.is_editor_hint() == false: remove_child(name_input)

		if edit:
			generate_nodes()
			update_nodes()
			if Engine.is_editor_hint() == false: add_child(name_input)
		else:
			save_to_store()

func _ready():
	remove_child(name_input)
	name_input.text = name
	Update.props(self, ["size", "edit"])

func opposite_corner(corner):
	return corners[7 - corners.find(corner)]

func clear_nodes():
	for i in range(corners.size()):
		remove_child(corners[i])
		corners[i].queue_free()

	for i in range(edges.size()):
		remove_child(edges[i])
		edges[i].queue_free()

	corners.clear()
	edges.clear()
	mesh.visible = false
	collision.disabled = true

func save_to_store():
	if Engine.is_editor_hint():
		return
	var areas = Store.house.state.areas
	var existing = -1

	for i in range(areas.size()):
		if areas[i].id == id:
			existing = i
			break

	if existing == - 1:
		areas.append({
			"id": id,
			"name": name_input.text,
			"position": global_position,
			"rotation": global_rotation,
			"size": size
		})
	else:
		areas[existing].name = name
		areas[existing].position = global_position
		areas[existing].rotation = global_rotation
		areas[existing].size = size

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

	mesh.visible = true
	collision.disabled = false

func update_area():
	area_collision.shape.size = size

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