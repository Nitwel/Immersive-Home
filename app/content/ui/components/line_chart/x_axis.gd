@tool
extends Control

const axil_label_theme = preload ("./axis_label.tres")

const WIDTH = 5000
const HEIGHT = 400

@onready var axis_labels = $AxisLabels

var minmax = Vector2(0, 100)
var axis_divisions = R.state(10.0)
var font_size = 80
var border_size = 10
var display_dates = true

func _draw():
	var base_axis = 20
	var dash_width = 30
	var text_pos = base_axis + dash_width

	for child in axis_labels.get_children():
		child.free()

	draw_line(Vector2(0, base_axis), Vector2(WIDTH, base_axis), Color(1, 1, 1), 10)

	var y_steps = WIDTH / axis_divisions.value

	for i in range(y_steps, WIDTH, y_steps):
		draw_line(Vector2(i, base_axis + dash_width), Vector2(i, base_axis), Color(1, 1, 1), 5)

		var font = get_theme_default_font()

		var relative_i = inverse_lerp(0, WIDTH, i)
		
		var text = ""
		if display_dates:
			text = Time.get_datetime_string_from_unix_time(lerp(minmax.x, minmax.y, relative_i)).substr(11, 5)
		else:
			text = str(round(lerp(minmax.x, minmax.y, relative_i) * 100) / 100)

		var label = Label.new()
		label.text = text
		label.label_settings = axil_label_theme
		label.position = Vector2(i, text_pos)

		axis_labels.add_child(label)