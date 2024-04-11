@tool
extends Control

const WIDTH = 400
const HEIGHT = 3000

var minmax = Vector2(0, 100)
var axis_divisions = R.state(10.0)
var font_size = 80
var border_size = 10

func _draw():
	var base_axis = WIDTH - 20
	var dash_width = -30
	var text_pos = base_axis + dash_width

	draw_line(Vector2(base_axis, 0), Vector2(base_axis, HEIGHT), Color(1, 1, 1), 10)

	var x_steps = HEIGHT / axis_divisions.value

	for i in range(x_steps, HEIGHT, x_steps):
		draw_line(Vector2(base_axis + dash_width, i), Vector2(base_axis, i), Color(1, 1, 1), 5)

		var font = get_theme_default_font()

		var relative_i = inverse_lerp(HEIGHT, 0, i)
		var text = str(round(lerp(minmax.x, minmax.y, relative_i) * 100) / 100)

		var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size + border_size)

		draw_string_outline(get_theme_default_font(), Vector2(text_pos - text_size.x, i + text_size.y / 4), text, HORIZONTAL_ALIGNMENT_LEFT, text_size.x, font_size, border_size, Color(0, 0, 0))
		draw_string(get_theme_default_font(), Vector2(text_pos - text_size.x, i + text_size.y / 4), text, HORIZONTAL_ALIGNMENT_LEFT, text_size.x, font_size, Color(1, 1, 1))