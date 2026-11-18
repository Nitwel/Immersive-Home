extends XRController3D

const Pointer = preload ("res://lib/utils/pointer/pointer.gd")
const Initiator = preload ("res://lib/utils/pointer/initiator.gd")
const Finger = preload ("res://lib/utils/touch/finger.gd")
const Touch = preload ("res://lib/utils/touch/touch.gd")
const Collide = preload ("res://lib/utils/touch/collide.gd")
const Miniature = preload ("res://content/system/miniature/miniature.gd")
const Entity = preload ("res://content/entities/entity.gd")

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
@onready var quick_actions = $Palm/QuickActions
@onready var entity_settings = $Palm/Settings
@onready var entity_settings_button = $Palm/Settings/SettingsButton

@export var show_grid = false:
	set(value):
		show_grid = value

		if ray != null:
			ray.with_grid = value

var hand_active = false:
	set(value):
		hand_active = value

		if pointer != null:
			pointer.set_physics_process(value)

var initiator: Initiator = Initiator.new()
var collide: Collide
var pointer: Pointer
var press_distance = 0.02
var grip_distance = 0.02

var pressed = false
var grabbed = false

var moving_entity = null

func _ready():
	_setup_hand()

	palm.remove_child(entity_settings)

	EventSystem.on_ray_enter.connect(func(event: EventPointer):
		if event.initiator.is_right() == true: return
		if moving_entity != null: return

		var entity=_get_entity(event.target)

		if entity != null&&entity.has_method("toggle_settings")&&entity_settings.is_inside_tree() == false:
			palm.add_child(entity_settings)
			moving_entity=entity
	)

	EventSystem.on_ray_leave.connect(func(event: EventPointer):
		if event.initiator.is_right() == true: return
		var entity=_get_entity(event.target)

		if moving_entity != null&&moving_entity == entity&&entity_settings.is_inside_tree():
			palm.remove_child(entity_settings)
			moving_entity=null
	)

	entity_settings_button.on_button_up.connect(func():
		if moving_entity == null:
			return

		moving_entity.toggle_settings()
	)

func _process(_delta):
	if !hand_active:
		if quick_actions.is_inside_tree(): palm.remove_child(quick_actions)
		return

	if App.camera.global_transform.basis.z.dot(palm.global_transform.basis.x) > 0.85:
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
		pointer.pressed(Initiator.EventType.TRIGGER)
		pressed = true
	elif !trigger_close&&pressed:
		pointer.released(Initiator.EventType.TRIGGER)
		pressed = false

	if grab_close&&!grabbed:
		pointer.pressed(Initiator.EventType.GRIP)
		grabbed = true
	elif !grab_close&&grabbed:
		pointer.released(Initiator.EventType.GRIP)
		grabbed = false

func _setup_hand():
	TouchManager.add_finger(Finger.Type.INDEX_LEFT, $IndexTip/TouchArea)

	collide = Collide.new(hand, hand_mesh, index_tip.get_node("Marker3D"))
	add_child(collide)

	auto_hand.hand_active_changed.connect(func(hand: int, active: bool):
		if hand != 0: return

		hand_active=active&&_is_hand_simulated() == false
			
		$IndexTip/TouchArea/CollisionShape3D.disabled=!hand_active
		hand_mesh.visible=hand_active
	)

	mini_view_button.on_button_up.connect(func():
		App.miniature.small.value=!App.miniature.small.value
	)

	temperature_button.on_button_up.connect(func():
		if App.miniature.heatmap_type.value == Miniature.HeatmapType.TEMPERATURE:
			App.miniature.heatmap_type.value=Miniature.HeatmapType.NONE
		else:
			App.miniature.heatmap_type.value=Miniature.HeatmapType.TEMPERATURE
	)

	humidity_button.on_button_up.connect(func():
		if App.miniature.heatmap_type.value == Miniature.HeatmapType.HUMIDITY:
			App.miniature.heatmap_type.value=Miniature.HeatmapType.NONE
		else:
			App.miniature.heatmap_type.value=Miniature.HeatmapType.HUMIDITY
	)

	initiator.type = Initiator.Type.HAND_LEFT
	initiator.node = self

	pointer = Pointer.new(initiator, ray)
	add_child(pointer)

func _is_hand_simulated():
	var hand_trackers = XRServer.get_trackers(XRServer.TRACKER_HAND)

	for tracker in hand_trackers.values():
		if tracker.hand != XRPositionalTracker.TrackerHand.TRACKER_HAND_LEFT:
			continue

		return tracker.hand_tracking_source == XRHandTracker.HAND_TRACKING_SOURCE_CONTROLLER

	return false

func _get_entity(node: Node):
	if node is Entity:
		return node

	if node.get_parent() == null:
		return null

	return _get_entity(node.get_parent())