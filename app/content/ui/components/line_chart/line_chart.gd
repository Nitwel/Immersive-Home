@tool

extends Node3D

@onready var mesh: MeshInstance3D = $Line
@onready var plane: MeshInstance3D = $Plane
@onready var x_axis: Control = $XAxis/SubViewport/XAxis
@onready var y_axis: Control = $YAxis/SubViewport/YAxis

const WIDTH = 0.001
const DEPTH = 0.0005
const STEPS = 5

@export var size: Vector2 = Vector2(0.5, 0.3)

var points = R.state([])
var show_dates = R.state(false)
var x_axis_label = R.state("X")
var y_axis_label = R.state("Y")

var minmax = R.computed(func(_arg):
	if points.value.size() == 0:
		return [Vector2(0, 0), Vector2(0, 0)]

	var min=points.value[0]
	var max=points.value[0]

	for point in points.value:
		min.x=min(min.x, point.x)
		min.y=min(min.y, point.y)
		max.x=max(max.x, point.x)
		max.y=max(max.y, point.y)

	return [min, max]
)

var relative_points = R.computed(func(_arg):
	var min=minmax.value[0]
	var max=minmax.value[1]

	return points.value.map(func(point):
		return Vector2(inverse_lerp(min.x, max.x, point.x), inverse_lerp(min.y, max.y, point.y))
	)
)

func _ready():
	for i in range(50):
		points.value.append(Vector2(i, sin(i / 8.0)))

	R.effect(func(_arg):
		mesh.mesh=generate_mesh(relative_points.value)
	)

	R.effect(func(_arg):
		x_axis.minmax=Vector2(minmax.value[0].x, minmax.value[1].x)
		y_axis.minmax=Vector2(minmax.value[0].y, minmax.value[1].y)
		y_axis.label=y_axis_label.value
		x_axis.queue_redraw()
		y_axis.queue_redraw()
	)

	plane.position = Vector3(size.x / 2, size.y / 2, -0.001)
	plane.mesh.size = size

func generate_mesh(points: Array):
	if points.size() < 2:
		return null

	var sf = SurfaceTool.new()

	sf.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

	for i in range(points.size()):
		var prev_point = points[i - 1] if i > 0 else (points[i] + Vector2( - 1, 0))
		var point = points[i]
		var next_point = points[i + 1] if i < points.size() - 1 else (points[i] + Vector2(1, 0))

		var prev_angle = (point - prev_point).angle_to(Vector2(1, 0))
		var next_angle = (next_point - point).angle_to(Vector2(1, 0))

		var angle = (prev_angle + next_angle) / 2.0

		var up = Vector2(0, 1).rotated( - angle)

		var p0 = (point + up * WIDTH * 2) * size
		var p1 = (point + up * - WIDTH * 2) * size

		sf.add_vertex(Vector3(p1.x, p1.y, DEPTH))
		sf.add_vertex(Vector3(p0.x, p0.y, DEPTH))

	sf.index()
	sf.generate_normals()

	var _mesh = sf.commit()

	return _mesh
		
