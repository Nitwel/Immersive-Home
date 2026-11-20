extends Node
## Lines the house up with the real home using a QR code fixed somewhere in it.
##
## The fallback for when the spatial anchor (house_anchor.gd) can't be found, e.g.
## after the boundary was cleared, and for headsets without the Meta anchor API.
##
## [method link] remembers where a QR code is while the rooms line up with the real
## home (qr_text, qr_transform in the house store, in the tracking space the house is
## saved in). [method align] finds the same code again: the difference between both
## poses is how much tracking space moved, and the house is moved back by it.

const HouseAnchor = preload ("./house_anchor.gd")

## Emitted when a link or align scan starts or ends.
signal on_busy_changed(busy: bool)

enum Mode {NONE, LINK, ALIGN}

## Detections averaged into one pose, single ones are a little noisy.
const SAMPLES = 6
## Seconds to find the QR code before giving up.
const SCAN_TIMEOUT = 30.0

var mode := Mode.NONE:
	set(value):
		if mode == value:
			return
		mode = value
		on_busy_changed.emit(value != Mode.NONE)

var _samples: Array[Transform3D] = []
## Content of the code being sampled, only one code counts per scan.
var _sample_text := ""

func _ready():
	QrScanner.on_marker.connect(_on_marker)
	QrScanner.on_timeout.connect(func():
		if mode == Mode.NONE:
			return
		mode=Mode.NONE
		EventSystem.notify("No QR code found.", EventNotify.Type.WARNING)
	)
	QrScanner.on_scanning_changed.connect(func(scanning):
		# Stopped from somewhere else. Deferred, a timeout is reported right after.
		if not scanning:
			(func():
				mode=Mode.NONE
			).call_deferred()
	)

func is_linked() -> bool:
	return str(Store.house.state.qr_text) != ""

## Remembers where the QR code in view is. The rooms have to line up with the real
## home right now.
func link():
	_start(Mode.LINK, "")

## Finds the linked QR code and moves the house back to where it belongs.
func align():
	if not is_linked():
		EventSystem.notify("Link a QR code first.", EventNotify.Type.WARNING)
		return

	_start(Mode.ALIGN, str(Store.house.state.qr_text))

## Stops a running link or align scan.
func cancel():
	if mode == Mode.NONE:
		return

	mode = Mode.NONE
	QrScanner.stop()

func _start(new_mode: Mode, text: String):
	if mode != Mode.NONE:
		cancel()
		return

	if QrScanner.scanning:
		EventSystem.notify("A QR code scan is already running.", EventNotify.Type.WARNING)
		return

	_samples.clear()
	_sample_text = text
	mode = new_mode

	var error = await QrScanner.start(SCAN_TIMEOUT, false)

	match error:
		QrScanner.ScanError.OK:
			if new_mode == Mode.LINK:
				EventSystem.notify("Look at the QR code to link, hold still for a moment.")
			else:
				EventSystem.notify("Look at the linked QR code, hold still for a moment.")
		QrScanner.ScanError.UNSUPPORTED:
			EventSystem.notify("QR code scanning isn't supported on this device. Meta Quest needs Horizon OS v83 or newer.", EventNotify.Type.WARNING)
		QrScanner.ScanError.PERMISSION_DENIED:
			EventSystem.notify("QR code scanning needs the spatial data permission.", EventNotify.Type.WARNING)

	if error != QrScanner.ScanError.OK&&mode == new_mode:
		mode = Mode.NONE

func _on_marker(text: String, pose: Transform3D):
	if mode == Mode.NONE:
		return

	# Linking takes the first code seen, aligning only the linked one.
	if _sample_text == "":
		_sample_text = text
	elif text != _sample_text:
		return

	_samples.append(App.main.xr_origin.global_transform * pose)

	if _samples.size() < SAMPLES:
		return

	var finished_mode = mode
	var marker = _average(_samples)
	mode = Mode.NONE
	QrScanner.stop()

	if finished_mode == Mode.LINK:
		_finish_link(marker)
	else:
		_finish_align(marker)

func _finish_link(marker: Transform3D):
	Store.house.state.qr_text = _sample_text
	Store.house.state.qr_transform = marker
	Store.house.save_local()

	EventSystem.notify("QR code linked. Scan it whenever the rooms are out of place.", EventNotify.Type.SUCCESS)

func _finish_align(marker: Transform3D):
	var saved: Transform3D = Store.house.state.qr_transform
	var shift = _get_shift(saved, marker)

	if HouseAnchor.is_negligible(shift):
		EventSystem.notify("The rooms already line up with the QR code.", EventNotify.Type.SUCCESS)
		return

	print("House QR: tracking space moved %.2fm and %.1f°, moving the house back" % [shift.origin.length(), rad_to_deg(abs(HouseAnchor.get_yaw(shift.basis)))])

	App.house.shift_house(shift)

	# Measured just now, more precise than the shifted pose.
	Store.house.state.qr_transform = marker
	Store.house.save_local()

	EventSystem.notify("Rooms lined up with the QR code.", EventNotify.Type.SUCCESS)

## The house was moved by [param shift] (see House.shift_house), so was the tracking
## space the QR code's pose is saved in.
func house_shifted(shift: Transform3D):
	if not is_linked():
		return

	Store.house.state.qr_transform = shift * Store.house.state.qr_transform

## How much tracking space moved, given where the code was ([param saved]) and is
## ([param now]). Only yaw and floor position, and exact at the code itself, so the
## farther from it, the more an error in the code's rotation shows.
static func _get_shift(saved: Transform3D, now: Transform3D) -> Transform3D:
	# Doesn't depend on how the runtime orients a code's axes, both poses share it.
	var turn = Basis(Vector3.UP, HouseAnchor.get_yaw(now.basis * saved.basis.inverse()))
	var origin = now.origin - turn * saved.origin
	origin.y = 0

	return Transform3D(turn, origin)

static func _average(transforms: Array[Transform3D]) -> Transform3D:
	var origin = Vector3.ZERO
	var first = transforms[0].basis.get_rotation_quaternion()
	var sum = Quaternion(0, 0, 0, 0)

	for transform in transforms:
		origin += transform.origin

		var rotation = transform.basis.get_rotation_quaternion()
		# q and -q are the same rotation, keep them on the same side before adding.
		if rotation.dot(first) < 0:
			rotation = -rotation
		sum += rotation

	return Transform3D(Basis(sum.normalized()), origin / transforms.size())
