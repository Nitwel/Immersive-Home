extends Node3D

const Miniature = preload ("res://content/system/miniature/miniature.gd")

@onready var mini_view_button = $Content/MiniView
@onready var heat_map_button = $Content/HeatMap
@onready var humudity_map_button = $Content/HumidityMap
@onready var min_slider = $Content/MinSlider
@onready var max_slider = $Content/MaxSlider
@onready var opacity_slider = $Content/OpacitySlider
@onready var background = $Background

func _ready():
	background.visible = false

	if App.miniature.is_node_ready() == false:
		await App.miniature.ready

	mini_view_button.on_toggled.connect(func(active):
		App.miniature.small.value=active
	)

	heat_map_button.on_toggled.connect(func(active):
		if active == false:
			if App.miniature.heatmap_type.value == Miniature.HeatmapType.TEMPERATURE:
				App.miniature.heatmap_type.value=Miniature.HeatmapType.NONE
			return

		App.miniature.heatmap_type.value=Miniature.HeatmapType.TEMPERATURE
	)

	humudity_map_button.on_toggled.connect(func(active):
		if active == false:
			if App.miniature.heatmap_type.value == Miniature.HeatmapType.HUMIDITY:
				App.miniature.heatmap_type.value=Miniature.HeatmapType.NONE
			return

		App.miniature.heatmap_type.value=Miniature.HeatmapType.HUMIDITY
	)

	R.effect(func(_arg):
		heat_map_button.active=App.miniature.heatmap_type.value == Miniature.HeatmapType.TEMPERATURE
		humudity_map_button.active=App.miniature.heatmap_type.value == Miniature.HeatmapType.HUMIDITY
	)

	min_slider.on_value_changed.connect(func(value):
		if value >= App.miniature.selected_scale.value.y:
			min_slider.value=App.miniature.selected_scale.value.y
			return

		App.miniature.selected_scale.value.x=value
	)

	max_slider.on_value_changed.connect(func(value):
		if value <= App.miniature.selected_scale.value.x:
			max_slider.value=App.miniature.selected_scale.value.x
			return
		
		App.miniature.selected_scale.value.y=value
	)

	R.effect(func(_arg):
		min_slider.value=App.miniature.selected_scale.value.x
		max_slider.value=App.miniature.selected_scale.value.y
	)

	# Update Slider
	R.effect(func(_arg):
		var minmax=App.miniature.get_base_scale()
		min_slider.min=minmax.x
		min_slider.max=minmax.y

		max_slider.min=minmax.x
		max_slider.max=minmax.y

		var sensor_minmax=App.miniature.get_sensor_scale()

		sensor_minmax.x=floor(sensor_minmax.x)
		sensor_minmax.y=ceil(sensor_minmax.y)

		App.miniature.selected_scale.value=sensor_minmax
		min_slider.value=sensor_minmax.x
		max_slider.value=sensor_minmax.y

		var unit=App.miniature.get_sensor_unit()

		min_slider.label_unit=unit
		max_slider.label_unit=unit
	)

	R.bind(opacity_slider, "value", App.miniature.opacity, opacity_slider.on_value_changed)
