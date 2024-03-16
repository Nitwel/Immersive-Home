extends RefCounted
class_name EntityFactory
## This class is used to create entities based on their type

const Switch = preload ("res://content/entities/switch/switch.tscn")
const Light = preload ("res://content/entities/light/light.tscn")
const Sensor = preload ("res://content/entities/sensor/sensor.tscn")
const MediaPlayer = preload ("res://content/entities/media_player/media_player.tscn")
const Camera = preload ("res://content/entities/camera/camera.tscn")
const ButtonEntity = preload ("res://content/entities/button/button.tscn")
const NumberEntity = preload ("res://content/entities/number/number.tscn")

static func create_entity(id: String):
	var entity = null
	var type = id.split(".")[0]

	match type:
		"switch":
			entity = Switch.instantiate()
		"light":
			entity = Light.instantiate()
		"sensor":
			entity = Sensor.instantiate()
		"media_player":
			entity = MediaPlayer.instantiate()
		"camera":
			entity = Camera.instantiate()
		"button":
			entity = ButtonEntity.instantiate()
		"number":
			entity = NumberEntity.instantiate()
		_:
			return null
			
	entity.entity_id = id
	return entity