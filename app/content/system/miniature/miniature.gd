extends Node3D

const ConstructRoomMesh = preload ("res://lib/utils/mesh/construct_room_mesh.gd")
const ConstructDoorMesh = preload ("res://lib/utils/mesh/construct_door_mesh.gd")
const wall_material = preload ("./mini_wall.tres")
const humidity_gradient = preload ("./humid_gradient.tres")
const temperature_gradient = preload ("./temp_gradient.tres")

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
var small = R.state(false)

func _ready():
	wall_material.set_shader_parameter("data", [])
	wall_material.set_shader_parameter("data_size", 0)

	EventSystem.on_action_down.connect(func(action):
		if action.name == "by_button":
			small.value=!small.value
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

## Puts the small model on a map: [param body_transform] is the global transform of
## the body (without scale), [param model_scale] the map's scale, and [param shown]
## whether the house lies on the shown part of the map.
func place_on_map(body_transform: Transform3D, model_scale: float, shown: bool):
	if not on_map:
		on_map = true
		if _size_tween != null:
			_size_tween.kill()
		# The pointer should land on the map below, for panning it.
		collision_shape.disabled = true
	body.global_transform = body_transform
	small_node.scale = Vector3.ONE * model_scale
	small_node.visible = shown

## Takes the small model off the map again, back in front of the user (or back to
## full size if the Mini View was turned off).
func leave_map():
	if not on_map:
		return
	on_map = false
	small_node.visible = true
	_update_size()

func _update_size():
	collision_shape.disabled = small.value == false or on_map
	player.visible = small.value

	if on_map and small.value:
		return # placed by the map

	if _size_tween != null:
		_size_tween.kill()
	var tween := create_tween()
	_size_tween = tween
	tween.set_parallel(true)
	if small.value:
		var aabb = App.house.get_rooms_aabb()
		var height = aabb.size.y

		aabb.position.y = -0.03
		aabb.size.y = 0.06

		var center = aabb.position + aabb.size / 2

		collision_shape.shape.size = aabb.size * 0.1
		collision_shape.position = center * 0.1
		entity_select.position = Vector3(0, height * 0.1 + 0.1, 0)

		var camera_position = App.camera.global_position
		var camera_direction = -App.camera.global_transform.basis.z

		camera_position.y *= 0.5
		camera_direction.y = 0

		var target_position = camera_position + camera_direction.normalized() * 0.5
		var new_position = target_position - center * 0.1

		tween.tween_property(small_node, "scale", Vector3(0.1, 0.1, 0.1), 0.5)
		tween.tween_property(body, "position", new_position, 0.5)
		# Coming off the map, it may still be turned to the map's north.
		tween.tween_property(body, "quaternion", Quaternion.IDENTITY, 0.5)
	else:
		tween.tween_property(small_node, "scale", Vector3.ONE, 0.5)
		tween.tween_property(body, "position", Vector3.ZERO, 0.5)
		tween.tween_property(body, "quaternion", Quaternion.IDENTITY, 0.5)

func _process(delta):
	var cam_pos = App.camera.global_position
	cam_pos.y += 0.1
	player.mesh.height = cam_pos.y
	player.position = Vector3(cam_pos.x, cam_pos.y / 2, cam_pos.z)

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
