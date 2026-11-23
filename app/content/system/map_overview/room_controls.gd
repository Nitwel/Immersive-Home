extends Node3D
## Controls for the rooms on the Map View (map_overview.gd), shown in place of the
## people list while the map is zoomed into the rooms: colour the dollhouse's floors
## by temperature or humidity, the value range the colours span, and how strongly
## they're drawn. All of it lives on the miniature (App.miniature).

const UI = preload ("res://content/entities/entity_ui.gd")
const Miniature = preload ("res://content/system/miniature/miniature.gd")

## Space the controls take: [param width] x [param height], centred on this node.
var width := 0.63
var height := 0.16

var _hint: Label3D
var _sliders := Node3D.new()

func _ready():
	var miniature = App.miniature
	if miniature == null: # not in the main scene (galleries)
		return
	if not miniature.is_node_ready():
		await miniature.ready

	var left = -width / 2.0
	var top = height / 2.0
	var row = 0.05

	UI.label(self, "Floor colours", 16, Vector3(left, top - 0.008, 0)).modulate = Color(1, 1, 1, 0.7)

	# Heat map toggles, left column
	var heat = _toggle("device_thermostat", "Temperature", Vector3(left + 0.0175, top - 0.04, 0))
	var humidity = _toggle("humidity_mid", "Humidity", Vector3(left + 0.0175, top - 0.04 - row, 0))

	heat.on_toggled.connect(func(active):
		_set_heatmap(Miniature.HeatmapType.TEMPERATURE, active)
	)
	humidity.on_toggled.connect(func(active):
		_set_heatmap(Miniature.HeatmapType.HUMIDITY, active)
	)
	R.effect(func(_arg):
		heat.active = miniature.heatmap_type.value == Miniature.HeatmapType.TEMPERATURE
		humidity.active = miniature.heatmap_type.value == Miniature.HeatmapType.HUMIDITY
	)

	# Range and strength, right column; only while a heat map is on.
	add_child(_sliders)
	var names_x = -0.06
	var slider_x = 0.1
	var min_slider = _slider("Min", Vector3(names_x, top - 0.04, 0), slider_x)
	var max_slider = _slider("Max", Vector3(names_x, top - 0.04 - row, 0), slider_x)
	var opacity_slider = _slider("Opacity", Vector3(names_x, top - 0.04 - row * 2, 0), slider_x)
	opacity_slider.min = 0
	opacity_slider.max = 100
	opacity_slider.step = 10
	opacity_slider.label_unit = "%"

	_hint = UI.label(self, "Turn on a heat map to colour\nthe rooms' floors by it.", 14, Vector3(names_x, top - 0.04 - row / 2.0, 0))
	_hint.modulate = Color(1, 1, 1, 0.6)

	R.effect(func(_arg):
		var on = miniature.heatmap_type.value != Miniature.HeatmapType.NONE
		UI.set_shown(_sliders, on)
		_hint.visible = not on
	)

	min_slider.on_value_changed.connect(func(value):
		if value >= miniature.selected_scale.value.y:
			min_slider.value = miniature.selected_scale.value.y
			return
		miniature.selected_scale.value.x = value
	)
	max_slider.on_value_changed.connect(func(value):
		if value <= miniature.selected_scale.value.x:
			max_slider.value = miniature.selected_scale.value.x
			return
		miniature.selected_scale.value.y = value
	)
	R.effect(func(_arg):
		min_slider.value = miniature.selected_scale.value.x
		max_slider.value = miniature.selected_scale.value.y
	)

	# A new heat map: its slider range, and the range its colours span by default, the
	# same as on the Home Assistant floor plan cards.
	R.effect(func(_arg):
		var minmax = miniature.get_base_scale()
		for slider in [min_slider, max_slider]:
			slider.min = minmax.x
			slider.max = minmax.y
			slider.label_unit = miniature.get_sensor_unit()

		var default_minmax = miniature.get_default_scale()
		min_slider.value = default_minmax.x
		max_slider.value = default_minmax.y
		# Deferred: states can't be written while an effect runs.
		(func(): miniature.selected_scale.value = default_minmax).call_deferred()
	)

	R.bind(opacity_slider, "value", miniature.opacity, opacity_slider.on_value_changed)

func _set_heatmap(type, active: bool):
	var miniature = App.miniature
	if active:
		miniature.heatmap_type.value = type
	elif miniature.heatmap_type.value == type:
		miniature.heatmap_type.value = Miniature.HeatmapType.NONE

func _toggle(icon_name: String, text: String, position: Vector3) -> Button3D:
	var button = UI.icon_button(self, icon_name, position, 0.035)
	button.toggleable = true
	UI.label(self, text, 16, position + Vector3(0.03, 0, 0))
	return button

## A slider with its name on the left, starting at [param name_position]; the
## slider is centred at [param slider_x] and shows its value on the right.
func _slider(text: String, name_position: Vector3, slider_x: float) -> Slider3D:
	UI.label(_sliders, text, 15, name_position)
	var slider = UI.slider(_sliders, Vector3(slider_x, name_position.y, 0), 0.19, 0.0, 1.0, 1.0)
	# Local state only, and the min / max clamping needs to run right away.
	slider.emit_interval = 0
	slider.show_label = true
	return slider
