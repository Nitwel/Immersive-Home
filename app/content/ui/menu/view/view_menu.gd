extends Node3D

const Miniature = preload ("res://content/system/house/mini/miniature.gd")

@onready var mini_view_button = $Content/MiniView
@onready var heat_map_button = $Content/HeatMap
@onready var humudity_map_button = $Content/HumidityMap
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
