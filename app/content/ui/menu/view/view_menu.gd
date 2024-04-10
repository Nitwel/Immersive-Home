extends Node3D

const Miniature = preload ("res://content/system/house/mini/miniature.gd")

@onready var mini_view_button = $Content/MiniView
@onready var heat_map_button = $Content/HeatMap
@onready var humudity_map_button = $Content/HumidityMap
@onready var min_slider = $Content/MinSlider
@onready var max_slider = $Content/MaxSlider
@onready var opacity_slider = $Content/OpacitySlider
@onready var background = $Background

func _ready():
	background.visible = false

	if !House.body.is_node_ready():
		await House.body.ready

	var mini_view = House.body.mini_view

	mini_view_button.on_toggled.connect(func(active):
		mini_view.small.value=active
	)

	heat_map_button.on_toggled.connect(func(active):
		if active == false:
			if mini_view.heatmap_type.value == Miniature.HeatmapType.TEMPERATURE:
				mini_view.heatmap_type.value=Miniature.HeatmapType.NONE
			return

		mini_view.heatmap_type.value=Miniature.HeatmapType.TEMPERATURE
	)

	humudity_map_button.on_toggled.connect(func(active):
		if active == false:
			if mini_view.heatmap_type.value == Miniature.HeatmapType.HUMIDITY:
				mini_view.heatmap_type.value=Miniature.HeatmapType.NONE
			return

		mini_view.heatmap_type.value=Miniature.HeatmapType.HUMIDITY
	)

	R.effect(func(_arg):
		heat_map_button.active=mini_view.heatmap_type.value == Miniature.HeatmapType.TEMPERATURE
		humudity_map_button.active=mini_view.heatmap_type.value == Miniature.HeatmapType.HUMIDITY
	)

	min_slider.on_value_changed.connect(func(value):
		if value >= mini_view.selected_scale.value.y:
			min_slider.value=mini_view.selected_scale.value.y
			return

		mini_view.selected_scale.value.x=value
	)

	max_slider.on_value_changed.connect(func(value):
		if value <= mini_view.selected_scale.value.x:
			max_slider.value=mini_view.selected_scale.value.x
			return
		
		mini_view.selected_scale.value.y=value
	)

	R.effect(func(_arg):
		min_slider.value=mini_view.selected_scale.value.x
		max_slider.value=mini_view.selected_scale.value.y
	)

	# Update Slider
	R.effect(func(_arg):
		var minmax=mini_view.get_base_scale()
		min_slider.min=minmax.x
		min_slider.max=minmax.y

		max_slider.min=minmax.x
		max_slider.max=minmax.y

		var sensor_minmax=mini_view.get_sensor_scale()

		sensor_minmax.x=floor(sensor_minmax.x)
		sensor_minmax.y=ceil(sensor_minmax.y)

		mini_view.selected_scale.value=sensor_minmax
		min_slider.value=sensor_minmax.x
		max_slider.value=sensor_minmax.y

		var unit=mini_view.get_sensor_unit()

		min_slider.label_unit=unit
		max_slider.label_unit=unit
	)

	R.bind(opacity_slider, "value", mini_view.opacity, opacity_slider.on_value_changed)
