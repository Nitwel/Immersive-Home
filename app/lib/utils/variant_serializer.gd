extends Object

## Convert a dictionary to be able to be serialized to JSON.
static func stringify_value(value):
	match typeof(value):
		TYPE_DICTIONARY:
			var new_dict = {}
			for key in value.keys():
				new_dict[key] = stringify_value(value[key])
			return new_dict
		TYPE_ARRAY:
			return value.map(func(item):
				return stringify_value(item)
			)
		TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING, TYPE_NIL:
			return value
		TYPE_STRING_NAME:
			return str(value)
		TYPE_VECTOR2:
			return {
				"x": value.x,
				"y": value.y,
				"_type": "Vector2"
			}
		TYPE_VECTOR3:
			return {
				"x": value.x,
				"y": value.y,
				"z": value.z,
				"_type": "Vector3"
			}
		TYPE_TRANSFORM3D:
			return {
				"origin": stringify_value(value.origin),
				"basis": stringify_value(value.basis),
				"_type": "Transform3D"
			}
		TYPE_BASIS:
			return {
				"x": stringify_value(value.x),
				"y": stringify_value(value.y),
				"z": stringify_value(value.z),
				"_type": "Basis"
			}
		TYPE_QUATERNION:
			return {
				"x": value.x,
				"y": value.y,
				"z": value.z,
				"w": value.w,
				"_type": "Quaternion"
			}
		_:
			assert(false, "Unsupported type: %s" % typeof(value))

## Restore a dictionary from a JSON-serialized dictionary.
static func parse_value(value):
	if typeof(value) == TYPE_ARRAY:
		return value.map(func(item):
			return parse_value(item)
		)
	elif typeof(value) == TYPE_DICTIONARY:
		if value.has("_type"):
			match value["_type"]:
				"Vector2":
					return Vector2(value["x"], value["y"])
				"Vector3":
					return Vector3(value["x"], value["y"], value["z"])
				"Transform3D":
					return Transform3D(parse_value(value["basis"]), parse_value(value["origin"]))
				"Basis":
					return Basis(parse_value(value["x"]), parse_value(value["y"]), parse_value(value["z"]))
				"Quaternion":
					return Quaternion(value["x"], value["y"], value["z"], value["w"])
				_:
					assert(false, "Unsupported type: %s" % value["_type"])
		else:
			var new_dict = {}
			for key in value.keys():
				new_dict[key] = parse_value(value[key])
			return new_dict
	else:
		return value
