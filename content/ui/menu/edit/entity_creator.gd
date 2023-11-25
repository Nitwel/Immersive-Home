extends Object

const Switch = preload("res://content/entities/switch/switch.tscn")
const Light = preload("res://content/entities/light/light.tscn")
const Sensor = preload("res://content/entities/sensor/sensor.tscn")

static func create_entity(type: String, id: String):
	var entity = null

	match type:
		"switch":
			entity = Switch.instantiate()
		"light":
			entity = Light.instantiate()
		"sensor":
			entity = Sensor.instantiate()
		_:
			return null

	entity.entity_id = id
	return entity