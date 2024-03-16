## Reduces the frequency of a signal by sampling and holding the data
static func sample_and_hold(data: PackedVector2Array, sample_rate: float) -> PackedFloat32Array:
	var new_data: PackedFloat32Array = PackedFloat32Array()
	new_data.resize(int(data.size() / sample_rate))

	var counter = 0.0

	for i in range(new_data.size()):
		new_data[i] = data[int(counter)].y
		counter += sample_rate

	return new_data