extends Area3D
class_name TouchBody3D

@export var plane = Plane.PLANE_XZ

func _ready():
	var collisionShape = null

	for child in get_children():
		if child is CollisionShape3D:
			collisionShape = child
			break

	if collisionShape != null:
		plane.d = collisionShape.shape.size.y / 2 + collisionShape.position.y
