extends RefCounted
## Builds the mesh for history paths on the 2D and 3D maps, like Home Assistant's
## map: a line through the recorded positions with a dot at each, fading out the
## older they are.

const PathShader = preload ("./path.gdshader")

const OLDEST_ALPHA = 0.15
const NEWEST_ALPHA = 0.9

## [param tracks]: [{points: PackedVector3Array (local, oldest first), color: Color}].
## [param normal]: the map's up direction (Z for the flat map, Y for the 3D ground).
static func build(tracks: Array, normal: Vector3, line_width: float, dot_size: float) -> ArrayMesh:
	var vertices = PackedVector3Array()
	var colors = PackedColorArray()
	var uvs = PackedVector2Array()
	var indices = PackedInt32Array()
	var axis_u = normal.cross(Vector3.FORWARD if abs(normal.z) < 0.9 else Vector3.RIGHT).normalized()
	var axis_v = normal.cross(axis_u).normalized()

	for track in tracks:
		var points: PackedVector3Array = track.points
		var count = points.size()
		if count == 0:
			continue
		var base_color: Color = track.color

		# Lines: one quad per segment
		for i in count - 1:
			var a = points[i]
			var b = points[i + 1]
			var direction = b - a
			if direction.length() < 0.00001:
				continue
			var across = direction.cross(normal).normalized() * line_width / 2.0
			var color = _faded(base_color, float(i + 1) / count)
			_quad(vertices, colors, uvs, indices, [a + across, b + across, b - across, a - across], color, false)

		# Dots on top of the line
		for i in count:
			var p = points[i]
			var half_u = axis_u * dot_size / 2.0
			var half_v = axis_v * dot_size / 2.0
			var color = _faded(base_color, float(i + 1) / count)
			_quad(vertices, colors, uvs, indices, [p - half_u - half_v, p + half_u - half_v, p + half_u + half_v, p - half_u + half_v], color, true)

	if indices.is_empty():
		return null

	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

static func material(ground_plane: bool) -> ShaderMaterial:
	var result = ShaderMaterial.new()
	result.shader = PathShader
	result.render_priority = 12
	result.set_shader_parameter("ground_plane", ground_plane)
	return result

## Newer positions are more opaque; [param age] goes from ~0 (oldest) to 1 (newest).
static func _faded(color: Color, age: float) -> Color:
	return Color(color.r, color.g, color.b, lerp(OLDEST_ALPHA, NEWEST_ALPHA, age))

static func _quad(vertices: PackedVector3Array, colors: PackedColorArray, uvs: PackedVector2Array, indices: PackedInt32Array, corners: Array, color: Color, dot: bool):
	var base = vertices.size()
	var corner_uvs = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)] if dot else [Vector2(-1, -1), Vector2(-1, -1), Vector2(-1, -1), Vector2(-1, -1)]
	for k in 4:
		vertices.append(corners[k])
		colors.append(color)
		uvs.append(corner_uvs[k])
	indices.append(base); indices.append(base + 1); indices.append(base + 2)
	indices.append(base); indices.append(base + 2); indices.append(base + 3)
