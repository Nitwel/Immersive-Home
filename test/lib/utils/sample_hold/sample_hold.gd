@tool
extends Node2D

const sample_hold = preload ("res://lib/utils/sample_hold.gd")

var data = PackedVector2Array()
var result: PackedFloat32Array

func _ready():
	print("test")
	for i in range(0, 44100):
		var value = sin(i * 2 * PI / 44100.0)
		data.push_back(Vector2(value, value))

	result = sample_hold.sample_and_hold(data, 44100.0 / 16000.0 * 1.5)

func _draw():
	var size = get_viewport().get_visible_rect().size
	size.x *= 10
	size.y *= 4
	var center = size / 2

	draw_line(Vector2(0, size.y / 2), Vector2(size.x, size.y / 2), Color(1, 1, 1))

	for i in range(0, data.size()):
		var value = data[i]
		var x = i * (size.x / data.size())

		draw_line(Vector2(x, 0), Vector2(x, value.x * center.y), Color(1, 0, 0))

	for i in range(0, result.size()):
		var value = result[i]
		var x = i * (size.x / result.size())

		draw_line(Vector2(x, 0), Vector2(x, value * center.y), Color(0, 1, 0))