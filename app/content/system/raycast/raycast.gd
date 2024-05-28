extends RayCast3D

const Pointer = preload ("res://lib/utils/pointer/pointer.gd")
const Initiator = preload ("res://lib/utils/pointer/initiator.gd")

@onready var cursor: Node3D = $Cursor
@onready var default_cursor: Sprite3D = $Cursor/DefaultCursor
@onready var retro_cursor: Sprite3D = $Cursor/RetroCursor
@onready var decal: Decal = $Decal
@onready var grid: MeshInstance3D = $Grid
@onready var wall_collider: RayCast3D = $WallCollider

@export var is_right: bool = true
@export var with_decal: bool = false
@export var with_grid: bool = false

@onready var pointer: Pointer
@onready var visual_ray: MeshInstance3D = $Ray

var _event_type_map = {
	"trigger_click": Initiator.EventType.TRIGGER,
	"grip_click": Initiator.EventType.GRIP,
}

func _ready():
	var initiator = Initiator.new()
	initiator.type = Initiator.Type.CONTROLLER_RIGHT if is_right else Initiator.Type.CONTROLLER_LEFT
	initiator.node = get_parent()
	assert(get_parent() is XRController3D, "Parent must be XRController3D")

	pointer = Pointer.new(initiator, self)
	add_child(pointer)

	get_parent().button_pressed.connect(func(button: String):
		EventSystem.emit_action(button, true, initiator)

		if _event_type_map.has(button):
			pointer.pressed(_event_type_map[button])
	)
	get_parent().button_released.connect(func(button: String):
		EventSystem.emit_action(button, false, initiator)

		if _event_type_map.has(button):
			pointer.released(_event_type_map[button])
	)

	get_parent().input_float_changed.connect(func(action_name, value):
		EventSystem.emit_action(action_name, value, initiator)
	)

	get_parent().input_vector2_changed.connect(func(action_name, value):
		EventSystem.emit_action(action_name, value, initiator)
	)

	R.effect(func(_arg):
		var style=Store.settings.state.cursor_style

		default_cursor.visible=style == 0
		retro_cursor.visible=style == 1
	)

func _physics_process(_delta):
	_handle_cursor()
	_handle_grid()

func _process(delta):
	if grid.visible:
		grid.material_override.set_shader_parameter("dot_offset", TransformTools.plane_2d_coords(grid.global_transform) / grid.mesh.size.x)

func _handle_grid():
	var collider = wall_collider.get_collider()

	if collider == null:
		grid.visible = false

	grid.visible = with_grid

	grid.global_position = wall_collider.get_collision_point() + wall_collider.get_collision_normal() * 0.01

	if abs(wall_collider.get_collision_normal().dot(Vector3.UP)) > 0.9:
		grid.global_transform.basis = Basis.looking_at(wall_collider.get_collision_normal(), Vector3.FORWARD, true)
	else:
		grid.global_transform.basis = Basis.looking_at(wall_collider.get_collision_normal(), Vector3.UP, true)

func _handle_cursor():
	var collider = get_collider()
	var distance = get_collision_point().distance_to(global_position)

	if collider == null:
		cursor.visible = false
		visual_ray.visible = true
		visual_ray.scale.y = 1
		if with_decal: decal.visible = true
		return

	if distance < 0.15:
		visual_ray.visible = false
	else:
		visual_ray.visible = true
		visual_ray.scale.y = clamp(distance * 2 - 0.1, 0.15, 1)

	cursor.visible = true
	decal.visible = false
	
	cursor.global_transform.origin = get_collision_point() + get_collision_normal() * 0.001 # offset to avoid z-fighting

	if abs(get_collision_normal().dot(Vector3.UP)) > 0.9:
		var ray_dir_inv = global_transform.basis.z
		cursor.global_transform.basis = Basis.looking_at(get_collision_normal().lerp(ray_dir_inv, 0.01), Vector3.UP, true)
	else:
		cursor.global_transform.basis = Basis.looking_at(get_collision_normal(), Vector3.UP, true)
		
	var cursor_scale = clamp(distance * 1.5 - 0.75, 1.0, 3.0)

	cursor.scale = Vector3(cursor_scale, cursor_scale, cursor_scale)
