extends RefCounted
## Streams stereo audio frames down to mono 16 bit PCM at a lower sample rate.
##
## Each output sample is the average of the input frames it covers (a box
## filter), which suppresses most of the aliasing that plain sample dropping
## causes. State is kept between calls so no frames are lost at chunk borders.

var ratio: float
var _acc := 0.0
var _count := 0
var _phase := 0.0

func _init(source_rate: float, target_rate: float):
	ratio = source_rate / target_rate

## Converts the given stereo frames. Returns little-endian signed 16 bit PCM
## and the peak absolute amplitude of the converted samples.
func process(frames: PackedVector2Array) -> Dictionary:
	var samples := PackedFloat32Array()
	samples.resize(int(frames.size() / ratio) + 2)
	var written := 0
	var peak := 0.0

	for frame in frames:
		_acc += (frame.x + frame.y) * 0.5
		_count += 1
		_phase += 1.0

		if _phase >= ratio:
			var value: float = clampf(_acc / _count, -1.0, 1.0)
			samples[written] = value
			written += 1
			peak = maxf(peak, absf(value))
			_acc = 0.0
			_count = 0
			_phase -= ratio

	var data := PackedByteArray()
	data.resize(written * 2)

	for i in range(written):
		data.encode_s16(i * 2, int(samples[i] * 32767.0))

	return {"data": data, "peak": peak}
