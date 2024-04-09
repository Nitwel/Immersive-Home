extends Node3D

const ConstructRoomMesh = preload ("res://lib/utils/mesh/construct_room_mesh.gd")
const wall_material = preload ("./mini_wall.tres")

@onready var walls_mesh = $Body/Model/WallsMesh
@onready var floor_mesh = $Body/Model/FloorMesh
@onready var collision_shape = $Body/CollisionShape3D
@onready var toggle_heatmap = $HeatmapButton

# var temperature_scale := Vector2( - 20.0, 60.0)
var temperature_scale := Vector2(22.0, 25.0)

var enabled = true:
	set(value):
		enabled = value
		update()

func _ready():
	update()

	if Store.house.is_loaded() == false:
		await Store.house.on_loaded

	if Store.house.state.rooms.size() == 0:
		return

	var room = Store.house.state.rooms[0]

	var corners = room.corners
	var height = room.height

	walls_mesh.mesh = ConstructRoomMesh.generate_wall_mesh_grid(corners, height)
	floor_mesh.mesh = ConstructRoomMesh.generate_ceiling_mesh_grid(corners)

	walls_mesh.material_override = wall_material
	floor_mesh.material_override = wall_material

	active = true
	EventSystem.on_slow_tick.connect(update_data)

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
