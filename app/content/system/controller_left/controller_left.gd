extends XRController3D

const Entity = preload ("res://content/entities/entity.gd")
const Pointer = preload ("res://lib/utils/pointer/pointer.gd")
const Initiator = preload ("res://lib/utils/pointer/initiator.gd")
const Finger = preload ("res://lib/utils/touch/finger.gd")
const Touch = preload ("res://lib/utils/touch/touch.gd")
const Collide = preload ("res://lib/utils/touch/collide.gd")
const Miniature = preload ("res://content/system/house/mini/miniature.gd")

@onready var main = $"/root/Main"
@onready var hand = $hand_l
@onready var hand_mesh = $hand_l/Armature/Skeleton3D/mesh_Hand_L
@onready var auto_hand = $AutoHandtracker

@onready var index_tip = $IndexTip
@onready var thumb_tip = $ThumbTip
@onready var middle_tip = $MiddleTip

@onready var mini_view_button = $Palm/QuickActions/MiniView
@onready var temperature_button = $Palm/QuickActions/Temperature
@onready var humidity_button = $Palm/QuickActions/Humidity

@onready var palm = $Palm
@onready var ray: RayCast3D = $Raycast
@onready var area = $trash_bin/Area3D
@onready var trash_bin = $trash_bin
@onready var animation = $AnimationPlayer
@onready var quick_actions = $Palm/QuickActions

var hand_active = false
var initiator: Initiator = Initiator.new()
var collide: Collide
var pointer: Pointer
var press_distance = 0.02
var grip_distance = 0.02

var pressed = false
var grabbed = false

var to_delete = []
var trash_bin_visible: bool = true:
	set(value):
		if trash_bin_visible == value:
			return

		if value:
			add_child(trash_bin)
		else:
			if animation.is_playing():
				await animation.animation_finished
			remove_child(trash_bin)

		trash_bin_visible = value

var trash_bin_large: bool = false:
	set(value):
		if trash_bin_large == value:
			return

		if value:
			animation.play("add_trashbin")
		else:
			animation.play_backwards("add_trashbin")

		trash_bin_large = value

func _ready():
	trash_bin_visible = false

	_setup_hand()

	EventSystem.on_grab_down.connect(func(event: EventPointer):
		trash_bin_visible=_get_entity(event.target) != null
	)

	EventSystem.on_grab_move.connect(func(event):
		if !trash_bin_visible:
			return

		var entity=_get_entity(event.target)

		if entity is Entity&&area.overlaps_body(entity):
			if !to_delete.has(entity):
				to_delete.append(entity)
			trash_bin_large=true
			
		else:
			to_delete.erase(entity)
			trash_bin_large=false
			
	)

	EventSystem.on_grab_up.connect(func(_event: EventPointer):
		if !trash_bin_visible:
			return

		for entity in to_delete:
			entity.queue_free()
		to_delete.clear()
		trash_bin_large=false
		trash_bin_visible=false

		House.body.save_all_entities()
	)

func _process(_delta):
	if !hand_active:
		if quick_actions.is_inside_tree(): palm.remove_child(quick_actions)
		return

	if main.camera.global_transform.basis.z.dot(palm.global_transform.basis.x) > 0.85:
		if quick_actions.is_inside_tree() == false: palm.add_child(quick_actions)
	else:
		if quick_actions.is_inside_tree(): palm.remove_child(quick_actions)

func _physics_process(_delta):
	if !hand_active: return

	var distance_trigger = index_tip.global_position.distance_to(thumb_tip.global_position)
	var distance_grab = middle_tip.global_position.distance_to(thumb_tip.global_position)

	var trigger_close = distance_trigger <= press_distance
	var grab_close = distance_grab <= grip_distance

	if trigger_close&&!pressed:
		initiator.on_press.emit(Initiator.EventType.TRIGGER)
		pressed = true
	elif !trigger_close&&pressed:
		initiator.on_release.emit(Initiator.EventType.TRIGGER)
		pressed = false

	if grab_close&&!grabbed:
		initiator.on_press.emit(Initiator.EventType.GRIP)
		grabbed = true
	elif !grab_close&&grabbed:
		initiator.on_release.emit(Initiator.EventType.GRIP)
		grabbed = false

func _get_entity(node: Node):
	if node is Entity:
		return node

	if node.get_parent() == null:
		return null

	return _get_entity(node.get_parent())

func _setup_hand():
	TouchManager.add_finger(Finger.Type.INDEX_LEFT, $IndexTip/TouchArea)

	collide = Collide.new(hand, hand_mesh, index_tip)
	add_child(collide)

	auto_hand.hand_active_changed.connect(func(hand: int, active: bool):
		if hand != 0: return

		hand_active=active
			
		$IndexTip/TouchArea/CollisionShape3D.disabled=!active
		hand_mesh.visible=active
	)

	mini_view_button.on_button_up.connect(func():
		House.body.mini_view.small.value=!House.body.mini_view.small.value
	)

	temperature_button.on_button_up.connect(func():
		if House.body.mini_view.heatmap_type.value == Miniature.HeatmapType.TEMPERATURE:
			House.body.mini_view.heatmap_type.value=Miniature.HeatmapType.NONE
		else:
			House.body.mini_view.heatmap_type.value=Miniature.HeatmapType.TEMPERATURE
	)

	humidity_button.on_button_up.connect(func():
		if House.body.mini_view.heatmap_type.value == Miniature.HeatmapType.HUMIDITY:
			House.body.mini_view.heatmap_type.value=Miniature.HeatmapType.NONE
		else:
			House.body.mini_view.heatmap_type.value=Miniature.HeatmapType.HUMIDITY
	)

	initiator.type = Initiator.Type.HAND_LEFT
	initiator.node = self

	pointer = Pointer.new(initiator, ray)
	add_child(pointer)