extends Node3D

const LineChart = preload ("./line_chart.gd")

@onready var close_button: Button3D = $Close
@onready var id_input: Input3D = $IDInput
@onready var duration_select: Select3D = $DurationSelect

var line_chart: LineChart

func _ready():
	line_chart = get_parent()

	close_button.on_button_up.connect(func():
		line_chart.show_settings.value=false
	)

	id_input.text = line_chart.entity_id

	R.bind(duration_select, "selected", line_chart.duration, duration_select.on_select)