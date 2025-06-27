extends RefCounted
class_name EntityFactory
## This class is used to create entities based on their type

const Switch = preload ("res://content/entities/switch/switch.tscn")
const Light = preload ("res://content/entities/light/light.tscn")
const Sensor = preload ("res://content/entities/sensor/sensor.tscn")
const MediaPlayer = preload ("res://content/entities/media_player/media_player.tscn")
const Camera = preload ("res://content/entities/camera/camera.tscn")
const ButtonEntity = preload ("res://content/entities/button/button.tscn")
const ChevronEntity = preload ("res://content/entities/chevron/chevron.tscn")
const StationEntity = preload("res://content/entities/station/station.tscn")
const CustomLabelEntity = preload("res://content/entities/custom_label/custom_label.tscn")
const NumberEntity = preload ("res://content/entities/number/number.tscn")
const LineGraphEntity = preload ("res://content/entities/line_chart/line_chart.tscn")
const TimerEntity = preload ("res://content/entities/timer/timer.tscn")
const WeatherEntity = preload ("res://content/entities/weather/weather.tscn")

static func isknownentity(entity_id: String):
	var type = entity_id.split(".")[0]
	return type in ["switch", "light", "sensor", "media_player",
					"camera", "button", "chevron", "station", "custom_label",
					"number", "line_chart", "timer", "weather", 
					"text" ]

static func create_entity(id: String, type=null):
	var entity = null

	if type == null:
		type = id.split(".")[0]

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
		"chevron":
			entity = ChevronEntity.instantiate()
		"station":
			entity = StationEntity.instantiate()
		"custom_label":
			entity = CustomLabelEntity.instantiate()
		"text":
			entity = StationEntity.instantiate()
		"number":
			entity = NumberEntity.instantiate()
		"line_chart":
			entity = LineGraphEntity.instantiate()
		"timer":
			entity = TimerEntity.instantiate()
		"weather":
			entity = WeatherEntity.instantiate()
		_:
			return null
			
	entity.entity_id = id
	return entity

static func get_entity_icon(type: String) -> String:
	match type:
		"switch":
			return "toggle_on"
		"light":
			return "lightbulb"
		"sensor":
			return "sensors"
		"media_player":
			return "play_circle"
		"camera":
			return "photo_camera"
		"button":
			return "radio_button_checked"
		"chevron":
			return "radio_button_checked"
		"station":
			return "sliders"
		"number":
			return "sliders"
		"line_chart":
			return "finance"
		"timer":
			return "timer"
		"weather":
			return "partly_cloudy_day"
		_:
			return "question_mark"
