extends Node3D

const ConstructRoomMesh = preload ("res://lib/utils/mesh/construct_room_mesh.gd")
const wall_material = preload ("./mini_wall.tres")

@onready var walls_mesh = $WallsMesh
@onready var floor_mesh = $FloorMesh
@onready var collision_shape = $CollisionShape3D
@onready var toggle_heatmap = $HeatmapButton

var enabled = true:
	set(value):
		enabled = value
		update()

func _ready():
	update()

	if Store.house.is_loaded() == false:
		await Store.house.on_loaded

	var room = Store.house.rooms[0]

	var corners = room.corners
	var height = room.height

	walls_mesh.mesh = ConstructRoomMesh.generate_wall_mesh_grid(corners, height)
	floor_mesh.mesh = ConstructRoomMesh.generate_ceiling_mesh_grid(corners)

	walls_mesh.material_override = wall_material
	floor_mesh.material_override = wall_material

	active = true
	update_data(0.0)

	toggle_heatmap.on_button_down.connect(func():
		active=true
		EventSystem.on_slow_tick.connect(update_data)
	)

	toggle_heatmap.on_button_up.connect(func():
		wall_material.set_shader_parameter("data", [])
		wall_material.set_shader_parameter("data_size", 0)
		active=false
		EventSystem.on_slow_tick.disconnect(update_data)
	)

func update():
	walls_mesh.visible = enabled
	floor_mesh.visible = enabled
	collision_shape.disabled = not enabled

const SensorEntity = preload ("res://content/entities/sensor/sensor.gd")

var active: bool = false

func update_data(delta: float) -> void:
	var data_list = []
	var min_max_data

	for room in House.body.get_rooms(0):
		for entity in room.get_node("Entities").get_children():
			if entity is SensorEntity:
				var sensor = entity as SensorEntity
				var data = sensor.get_sensor_data("temperature")
				if data == null:
					continue

				var sensor_pos = sensor.global_position

				if min_max_data == null:
					min_max_data = Vector2(float(data), float(data))
				else:
					min_max_data.x = min(min_max_data.x, float(data))
					min_max_data.y = max(min_max_data.y, float(data))

				data_list.append(Vector4(sensor_pos.x, sensor_pos.y, sensor_pos.z, float(data)))

	for data in data_list:
		data.w = (data.w - min_max_data.x) / (min_max_data.y - min_max_data.x)

	wall_material.set_shader_parameter("data", data_list)
	wall_material.set_shader_parameter("min_max_data", min_max_data)
	wall_material.set_shader_parameter("data_size", data_list.size())
