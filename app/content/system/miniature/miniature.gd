extends Node3D

const ConstructRoomMesh = preload ("res://lib/utils/mesh/construct_room_mesh.gd")
const ConstructDoorMesh = preload ("res://lib/utils/mesh/construct_door_mesh.gd")
const wall_material = preload ("./mini_wall.tres")
const humidity_gradient = preload ("./humid_gradient.tres")
const temperature_gradient = preload ("./temp_gradient.tres")
const MapOverview = preload ("res://content/system/map_overview/map_overview.gd")

@onready var body = $Body
@onready var small_node = $Body/Small
@onready var model = $Body/Small/Model
@onready var player = $Body/Small/Player
@onready var collision_shape = $Body/CollisionShape3D
@onready var entity_select = $Body/EntitySelect

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
var opacity = R.state(70)
var heatmap_type = R.state(HeatmapType.NONE)
## The rooms are shown small, standing on the Map View. Set through place_on_map /
## leave_map; there is no standalone small view.
var small = R.state(false)
## Whether the Map View is open (View menu, palm quick action, B button). The rooms
## are shown on it, at the home zone.
var map_view = R.state(false)
var _map_overview: MapOverview

func _ready():
	wall_material.set_shader_parameter("data", [])
	wall_material.set_shader_parameter("data_size", 0)

	EventSystem.on_action_down.connect(func(action):
		if action.name == "by_button":
			map_view.value=!map_view.value
	)

	R.effect(func(_arg):
		_show_map_overview(map_view.value)
	)

	if Store.house.is_loaded() == false:
		await Store.house.on_loaded

	# Update Room Mesh
	R.effect(func(_arg):
		if Store.house.state.rooms.size() == 0:
			return

		if heatmap_type.value == HeatmapType.NONE&&small.value == false:
			return

		for child in model.get_children():
			model.remove_child(child)
			child.free()

		for room in Store.house.state.rooms:
			var walls_mesh=MeshInstance3D.new()
			var floor_mesh=MeshInstance3D.new()

			model.add_child(walls_mesh)
			model.add_child(floor_mesh)

			var doors=[]

			for door in Store.house.state.doors:
				if door.room1 == room.name:
					doors.append([door.room1_position1, door.room1_position2])
				elif door.room2 == room.name:
					doors.append([door.room2_position1, door.room2_position2])

			walls_mesh.mesh=ConstructRoomMesh.generate_wall_mesh_with_doors_grid(room.corners, room.height, doors)
			floor_mesh.mesh=ConstructRoomMesh.generate_ceiling_mesh_grid(room.corners)

			walls_mesh.material_override=wall_material
			floor_mesh.material_override=wall_material

			walls_mesh.set_layer_mask_value(2, true)
			floor_mesh.set_layer_mask_value(2, true)

		for door in Store.house.state.doors:
			var door_mesh=MeshInstance3D.new()

			model.add_child(door_mesh)

			if Geometry2D.is_polygon_clockwise([
				Vector2(door.room1_position1.x, door.room1_position1.z),
				Vector2(door.room2_position1.x, door.room2_position1.z),
				Vector2(door.room2_position2.x, door.room2_position2.z),
				Vector2(door.room1_position2.x, door.room1_position2.z)
			]):
				door_mesh.mesh=ConstructDoorMesh.generate_door_mesh(door.room1_position2, door.room2_position2, door.room2_position1, door.room1_position1)
			else:
				door_mesh.mesh=ConstructDoorMesh.generate_door_mesh(door.room1_position1, door.room2_position1, door.room2_position2, door.room1_position2)

			door_mesh.material_override=wall_material

			door_mesh.set_layer_mask_value(2, true)
	)

	# Update Size
	R.effect(func(_arg):
		small.value
		_update_size()
	)

	# Update Walls
	R.effect(func(_arg):
		model.visible=heatmap_type.value != HeatmapType.NONE||small.value
	)

	# Update Heatmap
	R.effect(func(_arg):
		if heatmap_type.value != HeatmapType.NONE:
			EventSystem.on_slow_tick.connect(update_data)
			if heatmap_type.value == HeatmapType.TEMPERATURE:
				wall_material.set_shader_parameter("color_gradient", temperature_gradient)
			else:
				wall_material.set_shader_parameter("color_gradient", humidity_gradient)
		else:
			EventSystem.on_slow_tick.disconnect(update_data)
			wall_material.set_shader_parameter("data", [])
			wall_material.set_shader_parameter("data_size", 0)
	)

	R.effect(func(_arg):
		wall_material.set_shader_parameter("alpha", opacity.value / 100.0)
	)

var _size_tween: Tween
## True while the small model stands on the Map View (map_overview.gd), which then
## places it every frame through [method place_on_map].
var on_map := false

## Where the map the model stands on ends: [centre, up, radius] (world space), or
## null. Rooms and the player marker are cut off outside it.
var _map_disc = null

## Puts the small model on a map: [param body_transform] is the global transform of
## the body (without scale), [param model_scale] the map's scale, [param shown]
## whether to show it at all, and [param disc] the round map's [centre, up, radius]
## in world space, outside which it is cut off (null: not cut).
func place_on_map(body_transform: Transform3D, model_scale: float, shown: bool, disc = null):
	if not on_map:
		on_map = true
		if _size_tween != null:
			_size_tween.kill()
		if not small.value:
			small.value = true # builds the rooms; _update_size leaves the placing to us
	body.global_transform = body_transform
	small_node.scale = Vector3.ONE * model_scale
	small_node.visible = shown
	_map_disc = disc
	wall_material.set_shader_parameter("clip_to_disc", disc != null)
	if disc != null:
		wall_material.set_shader_parameter("disc_center", disc[0])
		wall_material.set_shader_parameter("disc_normal", disc[1])
		wall_material.set_shader_parameter("disc_radius", disc[2])

## Takes the model off the map again, back to full size (shown there only with a
## heat map).
func leave_map():
	if not on_map:
		return
	on_map = false
	small_node.visible = true
	_map_disc = null
	wall_material.set_shader_parameter("clip_to_disc", false)
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

func _update_size():
	# Small, the rooms stand on the Map View, which keeps the pointer for panning.
	collision_shape.disabled = true
	player.visible = small.value

	if small.value:
		return # placed by the map (place_on_map)

	if _size_tween != null:
		_size_tween.kill()
	var tween := create_tween()
	_size_tween = tween
	tween.set_parallel(true)
	tween.tween_property(small_node, "scale", Vector3.ONE, 0.5)
	tween.tween_property(body, "position", Vector3.ZERO, 0.5)
	tween.tween_property(body, "quaternion", Quaternion.IDENTITY, 0.5)

func _process(delta):
	var cam_pos = App.camera.global_position
	cam_pos.y += 0.1
	player.mesh.height = cam_pos.y
	player.position = Vector3(cam_pos.x, cam_pos.y / 2, cam_pos.z)
	if on_map:
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

	wall_material.set_shader_parameter("data", data_list)
	wall_material.set_shader_parameter("data_size", data_list.size())
