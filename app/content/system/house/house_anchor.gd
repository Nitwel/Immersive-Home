extends Node
## Keeps the house lined up with the real home across headset restarts.
##
## The house store keeps everything in the headset's tracking space, and the
## headset may put that space somewhere else after a restart or a boundary reset.
## A persistent spatial anchor, which the headset relocates from what it sees,
## marks the house's reference corner. The store remembers where that anchor was
## in the tracking space the house was saved in (anchor_position, anchor_yaw).
## Once the anchor is located again, the difference between the two poses is the
## amount the tracking space moved, and the whole house is moved back by it.
##
## Only the Meta anchor API is supported. Without it, or when the anchor can't be
## found, the manual align reference ("Fix" in the room menu) is the fallback.

const FloorPlan = preload ("res://lib/utils/floor_plan.gd")

## How long the anchor is given to be located before giving up for this session.
const LOAD_TIMEOUT = 20.0
## How long to wait after the anchor is first located, its pose settles meanwhile.
const SETTLE_TIME = 1.0
## Moves smaller than this are tracking noise and leave the house alone.
const MIN_SHIFT_DISTANCE = 0.01
const MIN_SHIFT_ANGLE = 0.5 * PI / 180.0

var anchor_manager = null

## The anchor the house is currently saved against, once located.
var _anchor_node: Node3D = null
var _anchor_uuid: StringName = &""
## The house was lined up with the anchor during this session.
var _aligned = false
var _started = false
var _creating = false
var _load_timer: SceneTreeTimer = null

func _ready():
	if OS.get_model_name() != "Quest"||not ClassDB.class_exists("OpenXRFbSpatialAnchorManager"):
		return

	anchor_manager = ClassDB.instantiate("OpenXRFbSpatialAnchorManager")
	anchor_manager.visible = false
	anchor_manager.openxr_fb_spatial_anchor_tracked.connect(_on_anchor_tracked)
	anchor_manager.openxr_fb_spatial_anchor_create_failed.connect(func(_transform=null, _custom_data=null):
		_creating=false
		push_warning("House anchor: creating the anchor failed")
	)
	anchor_manager.openxr_fb_spatial_anchor_load_failed.connect(func(_uuid=null, _custom_data=null, _extra=null):
		push_warning("House anchor: the saved anchor couldn't be loaded, creating a new one")
		_load_timer=null
		_create_anchor()
	)

	if App.main.is_node_ready() == false:
		await App.main.ready

	App.main.xr_origin.add_child(anchor_manager)
	App.main.xr.xr_started.connect(_start)

	# A house set up for the first time gets its anchor once its rooms are saved.
	Store.house.on_saved.connect(func():
		if _started&&not _creating&&str(Store.house.state.anchor_uuid) == ""&&Store.house.state.rooms.size() > 0:
			_create_anchor()
	)

func _is_supported() -> bool:
	if anchor_manager == null||not anchor_manager.is_inside_tree():
		return false

	if not Engine.has_singleton("OpenXRFbSpatialEntityExtension")||not Engine.has_singleton("OpenXRFbSpatialEntityStorageExtension"):
		return false

	return Engine.get_singleton("OpenXRFbSpatialEntityExtension").is_spatial_entity_supported()&&Engine.get_singleton("OpenXRFbSpatialEntityStorageExtension").is_spatial_entity_storage_supported()

## Runs every time the app gains focus, only the first one counts.
func _start():
	if _started:
		return

	if Store.house.is_loaded() == false:
		await Store.house.on_loaded

	if not anchor_manager.is_inside_tree():
		await anchor_manager.tree_entered

	if _started||not _is_supported():
		return
	_started = true

	var uuid = str(Store.house.state.anchor_uuid)

	if uuid == "":
		# Nothing set up yet, the anchor is created once the rooms are.
		if Store.house.state.rooms.size() > 0:
			_create_anchor()
		return

	_load_timer = get_tree().create_timer(LOAD_TIMEOUT)
	_load_timer.timeout.connect(func():
		if _load_timer != null&&_anchor_node == null:
			push_warning("House anchor: the saved anchor wasn't found in time, use the align reference to line up the rooms")
		_load_timer=null
	)
	anchor_manager.load_anchor(StringName(uuid))

## Saves the reference frame the user just confirmed as a new anchor, replacing the
## old one. Call whenever the house was lined up with the real home by hand.
func save():
	if not _started:
		return

	# Whatever the old anchor says no longer matters, the user lined it up.
	_aligned = true
	_load_timer = null
	_create_anchor()

func _create_anchor():
	if _creating:
		return
	_creating = true
	anchor_manager.create_anchor(FloorPlan.get_house_frame(Store.house.state), {"house": true})

func _on_anchor_tracked(anchor_node: Node3D, spatial_entity, is_new: bool):
	if is_new:
		_creating = false
		_replace_anchor(anchor_node, spatial_entity)
		return

	if str(spatial_entity.uuid) != str(Store.house.state.anchor_uuid)||_aligned:
		return

	_load_timer = null
	_anchor_node = anchor_node
	_anchor_uuid = spatial_entity.uuid

	await _wait_for_tracking(anchor_node)

	# The user lined up the house by hand meanwhile.
	if _aligned||_anchor_node != anchor_node:
		return

	while _is_house_busy():
		await get_tree().create_timer(1.0).timeout
		if _aligned||_anchor_node != anchor_node:
			return

	_align_house(anchor_node)

## A new anchor was created and saved, the house is now saved against it.
func _replace_anchor(anchor_node: Node3D, spatial_entity):
	var old_uuid = _anchor_uuid if _anchor_uuid != &"" else StringName(str(Store.house.state.anchor_uuid))

	_anchor_node = anchor_node
	_anchor_uuid = spatial_entity.uuid
	_aligned = true

	await _wait_for_tracking(anchor_node)
	if _anchor_node != anchor_node:
		return

	_store_anchor_pose(anchor_node)
	Store.house.save_local()

	if old_uuid != &""&&old_uuid != _anchor_uuid:
		_erase_anchor(old_uuid)

func _erase_anchor(uuid: StringName):
	var entity = anchor_manager.get_spatial_entity(uuid)

	if entity == null:
		return

	entity.openxr_fb_spatial_entity_erased.connect(func(_success=null, _location=null):
		anchor_manager.untrack_anchor(uuid)
	, CONNECT_ONE_SHOT)
	entity.erase_from_storage()

func _wait_for_tracking(anchor_node: Node3D):
	while is_instance_valid(anchor_node)&&anchor_node.has_method("get_has_tracking_data")&&not anchor_node.get_has_tracking_data():
		await get_tree().process_frame

	await get_tree().create_timer(SETTLE_TIME).timeout

func _is_house_busy() -> bool:
	return App.house.editing_room != null||App.house.align_reference.visible||App.house.doors.is_editing()||App.house.loaded.value == false

## Moves the whole house by how much the tracking space moved since it was saved.
func _align_house(anchor_node: Node3D):
	if not is_instance_valid(anchor_node):
		return

	var saved = _flat_transform(Store.house.state.anchor_position, float(Store.house.state.anchor_yaw))
	var now = _flat_transform(anchor_node.global_position, get_yaw(anchor_node.global_basis))
	var shift = now * saved.affine_inverse()

	_aligned = true

	if is_negligible(shift):
		return

	print("House anchor: tracking space moved %.2fm and %.1f°, moving the house back" % [shift.origin.length(), rad_to_deg(abs(get_yaw(shift.basis)))])

	App.house.shift_house(shift)

## The house was moved by [param shift] (see House.shift_house). The anchor's saved
## pose has to end up in the tracking space the house is now saved in.
func house_shifted(shift: Transform3D):
	if _is_tracking_saved_anchor():
		# The anchor knows where it is now, that's always right.
		_store_anchor_pose(_anchor_node)
		return

	# Not located (yet), it was saved in the tracking space the house was moved out of.
	Store.house.state.anchor_position = shift * Store.house.state.anchor_position
	Store.house.state.anchor_yaw = float(Store.house.state.anchor_yaw) + get_yaw(shift.basis)

func _is_tracking_saved_anchor() -> bool:
	if not is_instance_valid(_anchor_node)||str(_anchor_uuid) != str(Store.house.state.anchor_uuid):
		return false

	return not _anchor_node.has_method("get_has_tracking_data")||_anchor_node.get_has_tracking_data()

func _store_anchor_pose(anchor_node: Node3D):
	Store.house.state.anchor_uuid = str(_anchor_uuid)
	Store.house.state.anchor_position = Vector3(anchor_node.global_position.x, 0, anchor_node.global_position.z)
	Store.house.state.anchor_yaw = get_yaw(anchor_node.global_basis)

## Whether [param shift] is small enough to be tracking noise.
static func is_negligible(shift: Transform3D) -> bool:
	return shift.origin.length() < MIN_SHIFT_DISTANCE&&abs(get_yaw(shift.basis)) < MIN_SHIFT_ANGLE

## Turn around the up axis, ignoring any tilt from tracking noise.
static func get_yaw(basis: Basis) -> float:
	var forward = -basis.z
	forward.y = 0

	if forward.length_squared() < 0.000001:
		return 0.0

	return Vector3.FORWARD.signed_angle_to(forward, Vector3.UP)

## Only the yaw and floor position of [param transform], tracking space stays upright.
static func flatten(transform: Transform3D) -> Transform3D:
	return _flat_transform(transform.origin, get_yaw(transform.basis))

## Rooms stand on y = 0, so only the floor position and the yaw take part.
static func _flat_transform(position: Vector3, yaw: float) -> Transform3D:
	return Transform3D(Basis(Vector3.UP, yaw), Vector3(position.x, 0, position.z))
