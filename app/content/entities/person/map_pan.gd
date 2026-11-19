extends Node
## Drag-to-pan and two-hand zoom for map_view.gd and map_3d.gd.
##
## - One pointer: press on the map and move it; the spot that was pressed stays
##   under the pointer.
## - Two pointers: pull them apart to zoom in, push them together to zoom out; the
##   spots under both pointers stay under them, so the map follows the hands
##   smoothly (fractional zoom: the views magnify their nearest tile level).
##
## The owner forwards its press events: [method start] from _on_press_down and
## [method stop] from _on_press_up. While a drag is going on, [signal changed]
## reports the new centre and (fractional) zoom whenever they change.

const Tiles = preload ("./map_tiles.gd")

## Panel pixels (meters * PIXELS_PER_METER) the pointer has to move before the map
## follows, so the jitter of a held controller doesn't pan (and redraw) the map on
## a simple press.
const DEAD_ZONE = 4.0
## World pixels are measured at this zoom; deep enough for every map zoom.
const REFERENCE_ZOOM = 20

signal changed(center: Vector2, zoom: float)

## Each: {ray: RayCast3D, initiator}
var _pointers: Array = []
var _view = null
## Fractional zoom when the gesture (re)started, and the last one reported
var _zoom := 0.0
var _last_zoom := 0.0
## The pressed spot (one pointer) or the spot between both pointers (two), in world
## pixels at REFERENCE_ZOOM
var _anchor_px := Vector2.ZERO
var _start_offset := Vector2.ZERO
var _start_gap := 1.0
var _following := false

func _ready():
	set_process(false)

func is_panning() -> bool:
	return not _pointers.is_empty()

## Starts a drag, or turns one into a two-hand zoom, if [param event]'s ray hits
## [param view]'s map. Returns whether it did.
func start(event: EventPointer, view) -> bool:
	if event.ray == null or not view.is_visible_in_tree():
		return false
	if _pointers.size() >= 2 or _pointers.any(func(p): return p.initiator == event.initiator):
		return false
	if _view != null and _view != view:
		return false
	var offset = view.ray_offset(event.ray)
	if offset == null or not view.contains_offset(offset):
		return false

	_view = view
	_pointers.append({"ray": event.ray, "initiator": event.initiator})
	_anchor()
	set_process(true)
	return true

## Ends the drag of the pointer that sent [param event] (all of them without one).
## With one pointer left, it goes on panning from where it is.
func stop(event: EventPointer = null):
	if event == null:
		_pointers.clear()
	else:
		_pointers = _pointers.filter(func(p): return p.initiator != event.initiator)
	if _pointers.is_empty():
		_view = null
		set_process(false)
	else:
		_anchor()

## Panel pixels -> world pixels at REFERENCE_ZOOM, at fractional zoom [param zoom].
static func _to_world(panel_px: Vector2, zoom: float) -> Vector2:
	return panel_px * pow(2.0, REFERENCE_ZOOM - zoom)

## Takes the current pointer positions as the gesture's starting point.
func _anchor():
	var offsets = _offsets()
	if offsets == null:
		return
	_zoom = _view.get_fractional_zoom()
	_last_zoom = _zoom
	var center_px = Tiles.project(_view.center.x, _view.center.y, REFERENCE_ZOOM)
	if offsets.size() == 1:
		_start_offset = offsets[0]
		_anchor_px = center_px + _to_world(offsets[0], _zoom)
		_following = false
	else:
		_anchor_px = center_px + _to_world((offsets[0] + offsets[1]) / 2.0, _zoom)
		_start_gap = max(offsets[0].distance_to(offsets[1]), 1.0)
		_following = true

## Where each pointer hits the map (panel pixels from its centre), or null if one
## misses it. Hits far off the map, at a grazing angle, count as a miss too: they
## would throw the map across the world.
func _offsets():
	var result = []
	for pointer in _pointers:
		var offset = _view.ray_offset(pointer.ray)
		if offset == null or not _view.contains_offset(offset / 4.0):
			return null
		result.append(offset)
	return result

func _process(_delta):
	if not is_instance_valid(_view) or not _view.is_visible_in_tree() \
			or _pointers.any(func(p): return not is_instance_valid(p.ray)):
		stop()
		return
	# Zoomed by something else (a zoom button): carry on from the new view
	if not is_equal_approx(_view.get_fractional_zoom(), _last_zoom):
		_anchor()

	var offsets = _offsets()
	if offsets == null:
		return

	var zoom = _zoom
	var point = offsets[0]
	if offsets.size() == 1:
		if not _following:
			if point.distance_to(_start_offset) < DEAD_ZONE:
				return
			_following = true
	else:
		point = (offsets[0] + offsets[1]) / 2.0
		var gap = max(offsets[0].distance_to(offsets[1]), 1.0)
		zoom = clamp(_zoom + log(gap / _start_gap) / log(2.0), Tiles.MIN_ZOOM, Tiles.MAX_ZOOM)

	var center = Tiles.unproject(_anchor_px - _to_world(point, zoom), REFERENCE_ZOOM)
	if center != _view.center or not is_equal_approx(zoom, _last_zoom):
		_last_zoom = zoom
		changed.emit(center, zoom)
