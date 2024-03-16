extends StaticBody3D


func align_to_corners(from_pos: Vector3, to_pos: Vector3):
	var diff = to_pos - from_pos
	var direction = diff.normalized()
	var tangent = Vector3(direction.z, 0, -direction.x).normalized()

	if tangent == Vector3.ZERO:
		tangent = Vector3(1, 0, 0)

	var edge_position = from_pos + diff / 2

	var edge_basis = Basis(tangent, diff, tangent.cross(direction))
	
	transform = Transform3D(edge_basis, edge_position)
