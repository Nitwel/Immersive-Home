extends RayCast3D

const Pointer = preload ("res://lib/utils/pointer/pointer.gd")
const Initiator = preload ("res://lib/utils/pointer/initiator.gd")

@onready var cursor: Node3D = $Cursor
@onready var decal: Decal = $Decal

@export var is_right: bool = true
@export var with_decal: bool = false

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
		if _event_type_map.has(button):
			initiator.on_press.emit(_event_type_map[button])
	)
	get_parent().button_released.connect(func(button: String):
		if _event_type_map.has(button):
			initiator.on_release.emit(_event_type_map[button])
	)

func _physics_process(_delta):
	_handle_cursor()

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
	cursor.global_transform.basis = Basis.looking_at(get_collision_normal(), Vector3.UP)
