# QrScanner
**Inherits:** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html)

## Description

Scans QR codes with the headset cameras.

Uses the OpenXR spatial marker tracking extension (XR_EXT_spatial_marker_tracking). On Meta Quest this needs Horizon OS v83 or newer and the "Spatial Data" permission.  Detection only runs while a scan is active: [`start()`](#start) creates a QR code only spatial context and [`stop()`](#stop) frees it again, so the cameras aren't searching for codes the rest of the time.

## Properties

| Name                                                 | Type                                                                                                                                                                                           | Default |
| ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| [_component_data](#prop--component-data)             | [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[OpenXRSpatialComponentData](https://docs.godotengine.org/en/stable/classes/class_openxrspatialcomponentdata.html)\] | `[]`    |
| [_context](#prop--context)                           | [RID](https://docs.godotengine.org/en/stable/classes/class_rid.html)                                                                                                                           | `RID()` |
| [_discovery_cooldown](#prop--discovery-cooldown)     | [float](https://docs.godotengine.org/en/stable/classes/class_float.html)                                                                                                                       | `0.0`   |
| [_discovery_pending](#prop--discovery-pending)       | [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)                                                                                                                         | `false` |
| [_discovery_started_at](#prop--discovery-started-at) | [float](https://docs.godotengine.org/en/stable/classes/class_float.html)                                                                                                                       | `0.0`   |
| [_marker_tracking](#prop--marker-tracking)           | [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)                                                                                                                     | `null`  |
| [_scan_id](#prop--scan-id)                           | [int](https://docs.godotengine.org/en/stable/classes/class_int.html)                                                                                                                           | `0`     |
| [_scan_time_left](#prop--scan-time-left)             | [float](https://docs.godotengine.org/en/stable/classes/class_float.html)                                                                                                                       | `0.0`   |
| [_spatial_entities](#prop--spatial-entities)         | [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)                                                                                                                     | `null`  |
| [_stop_on_first](#prop--stop-on-first)               | [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)                                                                                                                         | `true`  |
| [scanning](#prop-scanning)                           | [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)                                                                                                                         | `false` |

## Methods

| Returns                                                                                                                                                                          | Name                                                                                                                                                                                                                                                                                          |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                                                                                                     | [_emit_marker](#-emit-marker) ( text: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), pose: [Transform3D](https://docs.godotengine.org/en/stable/classes/class_transform3d.html), scan_id: [int](https://docs.godotengine.org/en/stable/classes/class_int.html) ) |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                                                                                                     | [_finish](#-finish) ( text: [String](https://docs.godotengine.org/en/stable/classes/class_string.html), scan_id: [int](https://docs.godotengine.org/en/stable/classes/class_int.html) )                                                                                                       |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                                                                                                     | [_free_context](#-free-context) ( context: [RID](https://docs.godotengine.org/en/stable/classes/class_rid.html) )                                                                                                                                                                             |
| [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[OpenXRMarkerTracker](https://docs.godotengine.org/en/stable/classes/class_openxrmarkertracker.html)\] | [_get_marker_trackers](#-get-marker-trackers) ( context: [RID](https://docs.godotengine.org/en/stable/classes/class_rid.html) )                                                                                                                                                               |
| [String](https://docs.godotengine.org/en/stable/classes/class_string.html)                                                                                                       | [_marker_data_to_text](#-marker-data-to-text) ( data: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) )                                                                                                                                                          |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                                                                                                     | [_on_context_created](#-on-context-created) ( context: [RID](https://docs.godotengine.org/en/stable/classes/class_rid.html), scan_id: [int](https://docs.godotengine.org/en/stable/classes/class_int.html) )                                                                                  |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                                                                                                     | [_on_snapshot](#-on-snapshot) ( _snapshot: [RID](https://docs.godotengine.org/en/stable/classes/class_rid.html), processed: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html), context: [RID](https://docs.godotengine.org/en/stable/classes/class_rid.html) )           |
| void                                                                                                                                                                             | [_process](#-process) ( delta: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) )                                                                                                                                                                                     |
| void                                                                                                                                                                             | [_ready](#-ready) (  )                                                                                                                                                                                                                                                                        |
| [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)                                                                                                           | [_request_permission](#-request-permission) (  )                                                                                                                                                                                                                                              |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                                                                                                     | [_start_discovery](#-start-discovery) (  )                                                                                                                                                                                                                                                    |
| [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)                                                                                                           | [is_supported](#is-supported) (  )                                                                                                                                                                                                                                                            |
| [QrScanner.ScanError](/reference/QrScanner.html#enum-ScanError)                                                                                                                  | [start](#start) ( timeout: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) = `30.0`, stop_on_first: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) = `true` )                                                                                |
| [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)                                                                                                     | [stop](#stop) (  )                                                                                                                                                                                                                                                                            |

## Signals

### on_marker (text: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , pose: [Transform3D](https://docs.godotengine.org/en/stable/classes/class_transform3d.html)  ) {#on-marker}

Emitted for every QR code seen during a scan started with stop_on_first = false, with its pose in tracking space, as often as the codes are detected. The scan keeps running.

### on_scanned (text: [String](https://docs.godotengine.org/en/stable/classes/class_string.html)  ) {#on-scanned}

Emitted with the content of the first QR code found during a scan. The scan stops right after.

### on_scanning_changed (scanning: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html)  ) {#on-scanning-changed}

Emitted when a scan starts or stops.

### on_timeout ( ) {#on-timeout}

Emitted when a scan stops because no QR code was found in time.

## Enums

### enum ScanError {#enum-ScanError}

#### ScanError.OK = `0` {#const-OK}

No description provided yet.

#### ScanError.UNSUPPORTED = `1` {#const-UNSUPPORTED}

The device or runtime can't detect QR codes.

#### ScanError.PERMISSION_DENIED = `2` {#const-PERMISSION-DENIED}

The user didn't grant the permission needed for QR code detection.

#### ScanError.CANCELLED = `3` {#const-CANCELLED}

[`stop()`](#stop) was called before the scan started.

## Constants

### DEFAULT_TIMEOUT = `30.0` {#const-DEFAULT-TIMEOUT}

Seconds a scan runs before giving up.

### DISCOVERY_INTERVAL = `0.3` {#const-DISCOVERY-INTERVAL}

Seconds between two discovery requests while scanning.

### DISCOVERY_WATCHDOG = `3.0` {#const-DISCOVERY-WATCHDOG}

Seconds after which a discovery that never reported back is given up on.

### QUEST_SCENE_PERMISSION = `"com.oculus.permission.USE_SCENE"` {#const-QUEST-SCENE-PERMISSION}

Meta Quest only reports QR codes to apps with the Spatial Data permission.

## Property Descriptions

### _component_data: [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[OpenXRSpatialComponentData](https://docs.godotengine.org/en/stable/classes/class_openxrspatialcomponentdata.html)\] {#prop--component-data}

No description provided yet.

### _context: [RID](https://docs.godotengine.org/en/stable/classes/class_rid.html) {#prop--context}

No description provided yet.

### _discovery_cooldown: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) {#prop--discovery-cooldown}

No description provided yet.

### _discovery_pending: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#prop--discovery-pending}

No description provided yet.

### _discovery_started_at: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) {#prop--discovery-started-at}

No description provided yet.

### _marker_tracking: [Object](https://docs.godotengine.org/en/stable/classes/class_object.html) {#prop--marker-tracking}

No description provided yet.

### _scan_id: [int](https://docs.godotengine.org/en/stable/classes/class_int.html) {#prop--scan-id}

Increased on every start and stop, so callbacks of an old scan can tell they're stale.

### _scan_time_left: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) {#prop--scan-time-left}

No description provided yet.

### _spatial_entities: [Object](https://docs.godotengine.org/en/stable/classes/class_object.html) {#prop--spatial-entities}

No description provided yet.

### _stop_on_first: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#prop--stop-on-first}

No description provided yet.

### scanning: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#prop-scanning}

No description provided yet.

## Method Descriptions

### _emit_marker (text: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , pose: [Transform3D](https://docs.godotengine.org/en/stable/classes/class_transform3d.html) , scan_id: [int](https://docs.godotengine.org/en/stable/classes/class_int.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-emit-marker}

No description provided yet.

### _finish (text: [String](https://docs.godotengine.org/en/stable/classes/class_string.html) , scan_id: [int](https://docs.godotengine.org/en/stable/classes/class_int.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-finish}

No description provided yet.

### _free_context (context: [RID](https://docs.godotengine.org/en/stable/classes/class_rid.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-free-context}

No description provided yet.

### _get_marker_trackers (context: [RID](https://docs.godotengine.org/en/stable/classes/class_rid.html)  ) -> [Array](https://docs.godotengine.org/en/stable/classes/class_array.html)\[[OpenXRMarkerTracker](https://docs.godotengine.org/en/stable/classes/class_openxrmarkertracker.html)\] {#-get-marker-trackers}

No description provided yet.

### _marker_data_to_text (data: [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html)  ) -> [String](https://docs.godotengine.org/en/stable/classes/class_string.html) {#-marker-data-to-text}

No description provided yet.

### _on_context_created (context: [RID](https://docs.godotengine.org/en/stable/classes/class_rid.html) , scan_id: [int](https://docs.godotengine.org/en/stable/classes/class_int.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-on-context-created}

No description provided yet.

### _on_snapshot (_snapshot: [RID](https://docs.godotengine.org/en/stable/classes/class_rid.html) , processed: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) , context: [RID](https://docs.godotengine.org/en/stable/classes/class_rid.html)  ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-on-snapshot}

Called by the marker tracking capability once before (`processed` = false) and once after the snapshot has been turned into [OpenXRMarkerTracker](https://docs.godotengine.org/en/stable/classes/class_openxrmarkertracker.html)s.

### _process (delta: [float](https://docs.godotengine.org/en/stable/classes/class_float.html)  ) -> void {#-process}

No description provided yet.

### _ready ( ) -> void {#-ready}

No description provided yet.

### _request_permission ( ) -> [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#-request-permission}

No description provided yet.

### _start_discovery ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#-start-discovery}

No description provided yet.

### is_supported ( ) -> [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) {#is-supported}

Returns true if QR codes can be scanned on this device. Only reliable once the XR session is running.

### start (timeout: [float](https://docs.godotengine.org/en/stable/classes/class_float.html) = `30.0` , stop_on_first: [bool](https://docs.godotengine.org/en/stable/classes/class_bool.html) = `true`  ) -> [QrScanner.ScanError](/reference/QrScanner.html#enum-ScanError) {#start}

Starts scanning for QR codes. The first QR code found is emitted with [`on_scanned`](#on-scanned). With `stop_on_first` false, every detection is emitted with [`on_marker`](#on-marker) instead, until [`stop()`](#stop) is called or the scan times out. Returns once the scan is running or failed to start.

### stop ( ) -> [Variant](https://docs.godotengine.org/en/stable/classes/class_variant.html) {#stop}

Stops the current scan, if any.
