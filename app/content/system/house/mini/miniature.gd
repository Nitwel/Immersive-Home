extends Node3D

const ConstructRoomMesh = preload ("res://lib/utils/mesh/construct_room_mesh.gd")
const wall_material = preload ("./mini_wall.tres")

@onready var body = $Body
@onready var model = $Body/Model
@onready var collision_shape = $Body/CollisionShape3D
@onready var toggle_heatmap = $Body/HeatmapButton

enum HeatmapType {
	NONE = 0,
	TEMPERATURE = 1,
	HUMIDITY = 2
}

# var temperature_scale := Vector2( - 20.0, 60.0)
var temperature_scale := Vector2(22.0, 26.0)

var heatmap_type = R.state(HeatmapType.NONE)
var small = R.state(false)

func _ready():
	wall_material.set_shader_parameter("data", [])
	wall_material.set_shader_parameter("data_size", 0)

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

			walls_mesh.mesh=ConstructRoomMesh.generate_wall_mesh_grid(room.corners, room.height)
			floor_mesh.mesh=ConstructRoomMesh.generate_ceiling_mesh_grid(room.corners)

			walls_mesh.material_override=wall_material
			floor_mesh.material_override=wall_material
	)

	# Update Size
	R.effect(func(_arg):
		collision_shape.disabled=small.value == false

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
			tween.tween_property(model, "scale", Vector3.ONE, 0.5)
			tween.tween_property(body, "position", Vector3.ZERO, 0.5)
			tween.tween_property(body, "quaternion", Quaternion.IDENTITY, 0.5)
	)

	# Update Walls
	R.effect(func(_arg):
		var show_map=heatmap_type.value != HeatmapType.NONE
		var show_small=small.value

		for child in model.get_children():
			child.visible=show_map||show_small
	)

	# Update Heatmap
	R.effect(func(_arg):
		if heatmap_type.value != HeatmapType.NONE:
			EventSystem.on_slow_tick.connect(update_data)
		else:
			EventSystem.on_slow_tick.disconnect(update_data)
			wall_material.set_shader_parameter("data", [])
			wall_material.set_shader_parameter("data_size", 0)
	)

const SensorEntity = preload ("res://content/entities/sensor/sensor.gd")

# func _process(delta):
# 	for mesh in model.get_children():
# 		if mesh is MeshInstance3D:
# 			mesh.material_override.set_shader_parameter("mesh_pos", 

func update_data(_delta: float) -> void:
	var data_list = []

	for room in House.body.get_rooms(0):
		for entity in room.get_node("Entities").get_children():
			if entity is SensorEntity:
				var sensor = entity as SensorEntity
				var data = sensor.get_sensor_data("temperature")
				if data == null:
					continue

				var sensor_pos = House.body.to_local(sensor.global_position)

				data_list.append(Vector4(sensor_pos.x, sensor_pos.y, sensor_pos.z, float(data)))

	data_list = data_list.map(func(data: Vector4) -> Vector4:
		data.w=(data.w - temperature_scale.x) / (temperature_scale.y - temperature_scale.x)
		return data
	)

	wall_material.set_shader_parameter("data", data_list)
	wall_material.set_shader_parameter("data_size", data_list.size())
