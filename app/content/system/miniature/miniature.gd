extends Node3D
## The house's rooms on the Map View (content/system/map_overview), as a dollhouse
## (dollhouse.gd) at the home zone, to the map's scale. Also keeps whether the Map
## View is open, and the heat / humidity map, which colours the dollhouse's floors.

const humidity_gradient = preload ("./humid_gradient.tres")
const temperature_gradient = preload ("./temp_gradient.tres")
const MapOverview = preload ("res://content/system/map_overview/map_overview.gd")
const Dollhouse = preload ("./dollhouse.gd")

@onready var body = $Body
@onready var small_node = $Body/Small
@onready var player = $Body/Small/Player

enum HeatmapType {
	NONE = 0,
	TEMPERATURE = 1,
	HUMIDITY = 2
}

var heatmap_type_strings = {
	HeatmapType.NONE: "none",
	HeatmapType.TEMPERATURE: "temperature",
	HeatmapType.HUMIDITY: "humidity"
}

var base_scale = {
	HeatmapType.NONE: Vector2(0.0, 1.0),
	HeatmapType.TEMPERATURE: Vector2( - 20.0, 60.0),
	HeatmapType.HUMIDITY: Vector2(0.0, 100.0)
}
var selected_scale = R.state(Vector2(0.0, 1.0))
## How strongly the heat map colours the floors, in percent (Map View's Opacity)
var opacity = R.state(70)
var heatmap_type = R.state(HeatmapType.NONE)
## The rooms are shown, standing on the Map View. Set through place_on_map /
## leave_map.
var small = R.state(false)
## Whether the Map View is open (menu's map button, palm quick action, B button). The rooms
## are shown on it, at the home zone.
var map_view = R.state(false)
var _map_overview: MapOverview
var dollhouse := Dollhouse.new()
## What the dollhouse was last built from (a hash), to skip rebuilding it
var _dollhouse_key = null

func _ready():
	EventSystem.on_action_down.connect(func(action):
		if action.name == "by_button":
			map_view.value=!map_view.value
	)

	R.effect(func(_arg):
		# Deferred, out of the effect: closing takes the rooms off the map, which sets
		# `small`, and states can't be written while an effect runs.
		_show_map_overview.call_deferred(map_view.value)
	)

	dollhouse.visible = false
	small_node.add_child(dollhouse)

	if Store.house.is_loaded() == false:
		await Store.house.on_loaded

	# Build the dollhouse when shown, and only again when the house changed: opening
	# the Map View shouldn't stall the headset.
	R.effect(func(_arg):
		if Store.house.state.rooms.size() == 0 or not small.value:
			return
		var key = hash(str(Store.house.state.rooms) + str(Store.house.state.doors) + str(Store.house.state.entities))
		if key != _dollhouse_key:
			_dollhouse_key = key
			dollhouse.build(Store.house.state.rooms, Store.house.state.doors, Store.house.state.entities, App.house.global_transform.affine_inverse())
	)

	R.effect(func(_arg):
		dollhouse.visible=small.value
		player.visible=small.value
	)

	# Heat map on the dollhouse's floors; turning one on opens the Map View.
	R.effect(func(_arg):
		if heatmap_type.value != HeatmapType.NONE:
			EventSystem.on_slow_tick.connect(update_data)
			dollhouse.set_heat(temperature_gradient if heatmap_type.value == HeatmapType.TEMPERATURE else humidity_gradient)
			# Deferred: states can't be written while an effect runs.
			(func(): map_view.value = true).call_deferred()
		else:
			if EventSystem.on_slow_tick.is_connected(update_data):
				EventSystem.on_slow_tick.disconnect(update_data)
			dollhouse.set_heat(null)
			dollhouse.set_heat_data([])
	)

	R.effect(func(_arg):
		dollhouse.set_heat_strength(opacity.value / 100.0)
	)

## True while the rooms stand on the Map View (map_overview.gd), which then places
## them every frame through [method place_on_map].
var on_map := false

## Where the map the model stands on ends: [centre, up, radius] (world space), or
## null. Rooms and the player marker are cut off outside it.
var _map_disc = null

## Puts the rooms on a map: [param body_transform] is the global transform of the
## body (without scale), [param model_scale] the map's scale, [param shown] whether
## to show them at all, and [param disc] the round map's [centre, up, radius] in world
## space, outside which they are cut off (null: not cut). [param walls] (0..1): how
## far the dollhouse's walls have grown out of the floor.
func place_on_map(body_transform: Transform3D, model_scale: float, shown: bool, disc = null, walls := 1.0):
	if not on_map:
		on_map = true
		if not small.value:
			small.value = true # builds and shows the rooms
	body.global_transform = body_transform
	small_node.scale = Vector3.ONE * model_scale
	small_node.visible = shown
	_map_disc = disc
	dollhouse.set_view(walls, model_scale, disc)

## Takes the rooms off the map again (the Map View closed): hidden.
func leave_map():
	if not on_map:
		return
	on_map = false
	_map_disc = null
	small.value = false

## The Map View stays in the room after the menu closes. It is created on first use
## and kept (with its loaded history) while hidden.
func _show_map_overview(open: bool):
	if open:
		if _map_overview == null:
			_map_overview = MapOverview.new()
			_map_overview.on_close.connect(func(): map_view.value = false)
		if _map_overview.get_parent() == null:
			App.main.add_child(_map_overview)
			_map_overview.open_in_front_of(App.camera)
	elif _map_overview != null and _map_overview.get_parent() != null:
		_map_overview.get_parent().remove_child(_map_overview)

func _process(_delta):
	if not on_map:
		return
	var cam_pos = App.camera.global_position
	cam_pos.y += 0.1
	player.mesh.height = cam_pos.y
	player.position = Vector3(cam_pos.x, cam_pos.y / 2, cam_pos.z)
	player.visible = small.value and _on_disc(player.global_position)

## Whether a world position lies over the map the model stands on.
func _on_disc(point: Vector3) -> bool:
	if _map_disc == null:
		return true
	var offset: Vector3 = point - _map_disc[0]
	var normal: Vector3 = _map_disc[1]
	return (offset - offset.dot(normal) * normal).length() <= _map_disc[2]
const SensorEntity = preload ("res://content/entities/sensor/sensor.gd")

func get_base_scale() -> Vector2:
	return base_scale[heatmap_type.value]

func get_sensor_data():
	var data_list = []

	for room in App.house.get_rooms():
		for entity in room.get_node("Entities").get_children():
			if entity is SensorEntity:
				var sensor = entity as SensorEntity
				var data = sensor.get_sensor_data(heatmap_type_strings[heatmap_type.value])
				if data == null:
					continue

				var sensor_pos = App.house.to_local(sensor.global_position)

				data_list.append(Vector4(sensor_pos.x, sensor_pos.y, sensor_pos.z, float(data)))

	return data_list

func get_sensor_unit():
	for room in App.house.get_rooms():
		for entity in room.get_node("Entities").get_children():
			if entity is SensorEntity:
				var sensor = entity as SensorEntity
				var sensor_unit = sensor.get_sensor_unit(heatmap_type_strings[heatmap_type.value])
				if sensor_unit != null:
					return sensor_unit

	return ""

func get_sensor_scale():
	var data = get_sensor_data()
	var minmax

	for sensor in data:
		if minmax == null:
			minmax = Vector2(sensor.w, sensor.w)
		else:
			minmax.x = min(sensor.w, minmax.x)
			minmax.y = max(sensor.w, minmax.y)

	if minmax == null:
		return Vector2(0.0, 1.0)

	return minmax

func update_data(_delta: float) -> void:
	var data_list = get_sensor_data()

	data_list = data_list.map(func(data: Vector4) -> Vector4:
		data.w=clamp((data.w - selected_scale.value.x) / (selected_scale.value.y - selected_scale.value.x), 0.0, 1.0)
		return data
	)

	dollhouse.set_heat_data(data_list)
