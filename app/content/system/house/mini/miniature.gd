extends Node3D

const ConstructRoomMesh = preload ("res://lib/utils/mesh/construct_room_mesh.gd")
const wall_material = preload ("./mini_wall.tres")

@onready var body = $Body
@onready var model = $Body/Model
@onready var walls_mesh = $Body/Model/WallsMesh
@onready var floor_mesh = $Body/Model/FloorMesh
@onready var collision_shape = $Body/CollisionShape3D
@onready var toggle_heatmap = $Body/HeatmapButton

# var temperature_scale := Vector2( - 20.0, 60.0)
var temperature_scale := Vector2(22.0, 26.0)

var heatmap = R.state(false)
var small = R.state(false)

func _ready():
	if Store.house.is_loaded() == false:
		await Store.house.on_loaded

	R.effect(func(_arg):
		if Store.house.state.rooms.size() == 0:
			return

		if heatmap.value == false:
			return

		for room in Store.house.state.rooms:
			var corners=room.corners
			var height=room.height

			walls_mesh.mesh=ConstructRoomMesh.generate_wall_mesh_grid(corners, height)
			floor_mesh.mesh=ConstructRoomMesh.generate_ceiling_mesh_grid(corners)

			walls_mesh.material_override=wall_material
			floor_mesh.material_override=wall_material
	)

	R.bind(toggle_heatmap, "active", heatmap, toggle_heatmap.on_toggled)

	R.effect(func(_arg):
		var tween:=create_tween()
		tween.set_parallel(true)
		if small.value:

			var aabb=House.body.get_level_aabb(0)
			aabb.position.y=- 0.03
			aabb.size.y=0.06

			var center=aabb.position + aabb.size / 2

			collision_shape.shape.size=aabb.size * 0.1

			var camera=$"/root/Main/XROrigin3D/XRCamera3D"
			var camera_position=camera.global_position
			var camera_direction=- camera.global_transform.basis.z

			camera_position.y *= 0.5
			camera_direction.y=0

			var target_position=camera_position + camera_direction.normalized() * 0.2
			var new_position=target_position - center * 0.1

			tween.tween_property(model, "scale", Vector3(0.1, 0.1, 0.1), 0.5)
			tween.tween_property(body, "position", new_position, 0.5)
		else:
			tween.tween_property(model, "scale", Vector3(1, 1, 1), 0.5)
			tween.tween_property(body, "position", Vector3(0, 0, 0), 0.5)
	)

	R.effect(func(_arg):
		walls_mesh.visible=heatmap.value
		floor_mesh.visible=heatmap.value
		collision_shape.disabled=!heatmap.value

		if heatmap.value:
			EventSystem.on_slow_tick.connect(update_data)
		else:
			EventSystem.on_slow_tick.disconnect(update_data)
			wall_material.set_shader_parameter("data", [])
			wall_material.set_shader_parameter("data_size", 0)
	)

const SensorEntity = preload ("res://content/entities/sensor/sensor.gd")

func update_data(_delta: float) -> void:
	var data_list = []

	for room in House.body.get_rooms(0):
		for entity in room.get_node("Entities").get_children():
			if entity is SensorEntity:
				var sensor = entity as SensorEntity
				var data = sensor.get_sensor_data("temperature")
				if data == null:
					continue

				var sensor_pos = sensor.global_position

				data_list.append(Vector4(sensor_pos.x, sensor_pos.y, sensor_pos.z, float(data)))

	data_list = data_list.map(func(data: Vector4) -> Vector4:
		data.w=(data.w - temperature_scale.x) / (temperature_scale.y - temperature_scale.x)
		return data
	)

	wall_material.set_shader_parameter("data", data_list)
	wall_material.set_shader_parameter("data_size", data_list.size())
