extends RefCounted

static func get_corners_and_height() -> Dictionary:
	print("get corners")

	var lines = []
	var height = 2.8

	var walls = App.main.get_tree().get_nodes_in_group("meta_wall_face")

	for wall in walls:
		var mesh: MeshInstance3D = wall.wall_mesh

		var corner2 = mesh.to_global(Vector3( - mesh.mesh.size.x / 2.0, 0, 0))
		var corner1 = mesh.to_global(Vector3(mesh.mesh.size.x / 2.0, 0, 0))

		corner1 = Vector2(corner1.x, corner1.z)
		corner2 = Vector2(corner2.x, corner2.z)

		height = mesh.mesh.size.y
		lines.append([corner1, corner2])

	return {
		"corners": lines_to_polygon(lines),
		"height": height
	}

static func lines_to_polygon(lines: Array) -> Array:
	var polygon = [lines[0][0],lines[0][1]]
	var added_lines = [0]

	while len(polygon) < len(lines):
		for i in range(len(lines)):
			if i in added_lines:
				continue

			if polygon[- 1].distance_to(lines[i][0]) < 0.01:
				polygon.append(lines[i][1])
				added_lines.append(i)
			elif polygon[- 1].distance_to(lines[i][1]) < 0.01:
				polygon.append(lines[i][0])
				added_lines.append(i)

	return polygon