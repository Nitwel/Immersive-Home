extends RefCounted
## Description of a finger area.

enum Type {
	THUMB_RIGHT,
	INDEX_RIGHT,
	MIDDLE_RIGHT,
	RING_RIGHT,
	LITTLE_RIGHT,
	THUMB_LEFT,
	INDEX_LEFT,
	MIDDLE_LEFT,
	RING_LEFT,
	LITTLE_LEFT,
}

var type: Type
var area: Area3D
## Global position of [member area] at the last physics tick where it was
## somewhere else. Lets receivers tell which side a touch came from, which the
## current position can't do when the finger moves far in a single tick.
var previous_position: Vector3