extends Node
## Scans QR codes with the headset cameras.
##
## Uses the OpenXR spatial marker tracking extension (XR_EXT_spatial_marker_tracking).
## On Meta Quest this needs Horizon OS v83 or newer and the "Spatial Data" permission.
##
## Detection only runs while a scan is active: [method start] creates a QR code only
## spatial context and [method stop] frees it again, so the cameras aren't
## searching for codes the rest of the time.

## Emitted with the content of the first QR code found during a scan. The scan stops right after.
signal on_scanned(text: String)
## Emitted for every QR code seen during a scan started with stop_on_first = false, with its
## pose in tracking space, as often as the codes are detected. The scan keeps running.
signal on_marker(text: String, pose: Transform3D)
## Emitted when a scan starts or stops.
signal on_scanning_changed(scanning: bool)
## Emitted when a scan stops because no QR code was found in time.
signal on_timeout()

enum ScanError {
	OK,
	## The device or runtime can't detect QR codes.
	UNSUPPORTED,
	## The user didn't grant the permission needed for QR code detection.
	PERMISSION_DENIED,
	## [method stop] was called before the scan started.
	CANCELLED,
}

## Meta Quest only reports QR codes to apps with the Spatial Data permission.
const QUEST_SCENE_PERMISSION = "com.oculus.permission.USE_SCENE"
## Seconds between two discovery requests while scanning.
const DISCOVERY_INTERVAL = 0.3
## Seconds after which a discovery that never reported back is given up on.
const DISCOVERY_WATCHDOG = 3.0
## Seconds a scan runs before giving up.
const DEFAULT_TIMEOUT = 30.0

var scanning := false:
	set(value):
		if scanning == value:
			return

		scanning = value
		on_scanning_changed.emit(value)

var _spatial_entities: Object = null
var _marker_tracking: Object = null

## Increased on every start and stop, so callbacks of an old scan can tell they're stale.
var _scan_id := 0
var _context := RID()
var _discovery_pending := false
var _discovery_started_at := 0.0
var _discovery_cooldown := 0.0
var _scan_time_left := 0.0
var _component_data: Array[OpenXRSpatialComponentData] = []
var _stop_on_first := true

func _ready():
	set_process(false)

## Returns true if QR codes can be scanned on this device.
## Only reliable once the XR session is running.
func is_supported() -> bool:
	if _marker_tracking == null && Engine.has_singleton("OpenXRSpatialMarkerTrackingCapability"):
		_marker_tracking = Engine.get_singleton("OpenXRSpatialMarkerTrackingCapability")
		_spatial_entities = Engine.get_singleton("OpenXRSpatialEntityExtension")

	return _marker_tracking != null && _spatial_entities != null && _marker_tracking.is_qrcode_supported()

## Starts scanning for QR codes. The first QR code found is emitted with [signal on_scanned].
## With [param stop_on_first] false, every detection is emitted with [signal on_marker]
## instead, until [method stop] is called or the scan times out.
## Returns once the scan is running or failed to start.
func start(timeout: float = DEFAULT_TIMEOUT, stop_on_first := true) -> ScanError:
	if scanning:
		return ScanError.OK

	if is_supported() == false:
		return ScanError.UNSUPPORTED

	_stop_on_first = stop_on_first
	_scan_id += 1
	var scan_id = _scan_id
	scanning = true

	if await _request_permission() == false:
		if scan_id == _scan_id:
			scanning = false
		return ScanError.PERMISSION_DENIED

	if scan_id != _scan_id:
		return ScanError.CANCELLED

	var configurations: Array[OpenXRSpatialCapabilityConfigurationBaseHeader] = [OpenXRSpatialCapabilityConfigurationQrCode.new()]
	var future = _spatial_entities.create_spatial_context(configurations, null, _on_context_created.bind(scan_id))

	if future == null:
		scanning = false
		return ScanError.UNSUPPORTED

	_scan_time_left = timeout
	_discovery_cooldown = 0.0
	set_process(true)

	return ScanError.OK

## Stops the current scan, if any.
func stop():
	if scanning == false:
		return

	_scan_id += 1
	scanning = false
	set_process(false)

	# A running discovery still uses the context, so it's freed once that reports back.
	if _discovery_pending == false:
		_free_context(_context)

	_context = RID()

func _process(delta: float):
	_scan_time_left -= delta

	if _scan_time_left <= 0.0:
		stop()
		on_timeout.emit()
		return

	if _context.is_valid() == false:
		return

	if _discovery_pending:
		if Time.get_ticks_msec() / 1000.0 - _discovery_started_at < DISCOVERY_WATCHDOG:
			return

		# The runtime never answered, request a new snapshot.
		_discovery_pending = false

	_discovery_cooldown -= delta

	if _discovery_cooldown > 0.0:
		return

	_discovery_cooldown = DISCOVERY_INTERVAL
	_start_discovery()

func _start_discovery():
	if _component_data.is_empty():
		# The query result data has to come first, the marker list provides the QR code content.
		_component_data.append(OpenXRSpatialQueryResultData.new())
		_component_data.append(OpenXRSpatialComponentMarkerList.new())

	var context = _context
	var future = _marker_tracking.start_entity_discovery(context, _component_data, null, null, _on_snapshot.bind(context))

	if future != null:
		_discovery_pending = true
		_discovery_started_at = Time.get_ticks_msec() / 1000.0

func _on_context_created(context: RID, scan_id: int):
	if scan_id != _scan_id||scanning == false:
		_free_context(context)
		return

	_context = context

## Called by the marker tracking capability once before ([param processed] = false) and once after
## the snapshot has been turned into [OpenXRMarkerTracker]s.
func _on_snapshot(_snapshot: RID, processed: bool, context: RID):
	if processed == false:
		return

	_discovery_pending = false

	# The snapshot is only freed after this callback returns, so the context
	# must stay alive until then. Hence the deferred calls.
	if context != _context:
		# The scan was stopped while this discovery was running.
		_free_context.call_deferred(context)
		return

	for tracker in _get_marker_trackers(context):
		if tracker.marker_type != OpenXRSpatialComponentMarkerList.MARKER_TYPE_QRCODE:
			continue

		if tracker.spatial_tracking_state != OpenXRSpatialEntityTracker.ENTITY_TRACKING_STATE_TRACKING:
			continue

		var text = _marker_data_to_text(tracker.get_marker_data())

		if text == "":
			continue

		if _stop_on_first:
			_finish.call_deferred(text, _scan_id)
			return

		if tracker.has_pose(&"default"):
			_emit_marker.call_deferred(text, tracker.get_pose(&"default").transform, _scan_id)

func _emit_marker(text: String, pose: Transform3D, scan_id: int):
	if scan_id != _scan_id:
		return

	on_marker.emit(text, pose)

func _finish(text: String, scan_id: int):
	if scan_id != _scan_id:
		return

	stop()
	on_scanned.emit(text)

func _free_context(context: RID):
	if context.is_valid() == false:
		return

	# The capability registers a tracker for every detected code. Nothing updates them
	# once the context is gone, so they're taken off the XRServer.
	for tracker in _get_marker_trackers(context):
		XRServer.remove_tracker(tracker)

	_spatial_entities.free_spatial_context(context)

func _get_marker_trackers(context: RID) -> Array[OpenXRMarkerTracker]:
	var result: Array[OpenXRMarkerTracker] = []

	for tracker in XRServer.get_trackers(XRServer.TRACKER_ANY).values():
		if tracker is OpenXRMarkerTracker&&tracker.get_spatial_context() == context:
			result.append(tracker)

	return result

func _marker_data_to_text(data: Variant) -> String:
	if data is String:
		return data.strip_edges()

	if data is PackedByteArray:
		return data.get_string_from_utf8().strip_edges()

	return ""

func _request_permission() -> bool:
	if OS.get_name() != "Android"||OS.get_model_name() != "Quest":
		return true

	if OS.request_permission(QUEST_SCENE_PERMISSION):
		return true

	# Other permission requests may finish in between, wait for ours.
	var result: Array = []
	while result.is_empty()||result[0] != QUEST_SCENE_PERMISSION:
		result = await get_tree().on_request_permissions_result

	return result[1]
