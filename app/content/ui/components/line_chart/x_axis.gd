@tool
extends Control

func _draw():
	draw_line(Vector2(380, 0), Vector2(380, 3000), Color(1, 1, 1), 10)

	for i in range(100, 3000, 100):
		draw_line(Vector2(350, i), Vector2(380, i), Color(1, 1, 1), 5)
		draw_string_outline(get_theme_default_font(), Vector2(240, i + 15), str(i), HORIZONTAL_ALIGNMENT_RIGHT, 100, 40, 10, Color(0, 0, 0))
		draw_string(get_theme_default_font(), Vector2(240, i + 15), str(i), HORIZONTAL_ALIGNMENT_RIGHT, 100, 40, Color(1, 1, 1))