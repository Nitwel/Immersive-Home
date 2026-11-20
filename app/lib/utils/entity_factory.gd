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
const LineGraphEntity = preload ("res://content/entities/line_chart/line_chart.tscn")
const TimerEntity = preload ("res://content/entities/timer/timer.tscn")
const WeatherEntity = preload ("res://content/entities/weather/weather.tscn")
const BinarySensorEntity = preload ("res://content/entities/binary_sensor/binary_sensor.tscn")
const SelectEntity = preload ("res://content/entities/select/select.tscn")
const ClimateEntity = preload ("res://content/entities/climate/climate.tscn")
const LockEntity = preload ("res://content/entities/lock/lock.tscn")
const TextEntity = preload ("res://content/entities/text/text.tscn")
const DateTimeEntity = preload ("res://content/entities/datetime/datetime.tscn")
const CoverEntity = preload ("res://content/entities/cover/cover.tscn")
const FanEntity = preload ("res://content/entities/fan/fan.tscn")
const VacuumEntity = preload ("res://content/entities/vacuum/vacuum.tscn")
const AlarmEntity = preload ("res://content/entities/alarm_control_panel/alarm_control_panel.tscn")
const HumidifierEntity = preload ("res://content/entities/humidifier/humidifier.tscn")
const WaterHeaterEntity = preload ("res://content/entities/water_heater/water_heater.tscn")
const SunEntity = preload ("res://content/entities/sun/sun.tscn")
const ZoneEntity = preload ("res://content/entities/zone/zone.tscn")
const UpdateEntity = preload ("res://content/entities/update/update.tscn")
const EventEntity = preload ("res://content/entities/event/event.tscn")
const ImageEntity = preload ("res://content/entities/image/image.tscn")
const AirQualityEntity = preload ("res://content/entities/air_quality/air_quality.tscn")
const CalendarEntity = preload ("res://content/entities/calendar/calendar.tscn")
const TodoEntity = preload ("res://content/entities/todo/todo.tscn")

## Widget used for each Home Assistant domain. Several domains share a widget when
## they behave the same (e.g. input_boolean is a switch, scene/script are pressed once).
const SCENES = {
	"switch": Switch,
	"input_boolean": Switch,
	"automation": Switch,
	"light": Light,
	"sensor": Sensor,
	"counter": Sensor,
	"binary_sensor": BinarySensorEntity,
	"media_player": MediaPlayer,
	"camera": Camera,
	"button": ButtonEntity,
	"input_button": ButtonEntity,
	"scene": ButtonEntity,
	"script": ButtonEntity,
	"number": NumberEntity,
	"input_number": NumberEntity,
	"timer": TimerEntity,
	"weather": WeatherEntity,
	"select": SelectEntity,
	"input_select": SelectEntity,
	"climate": ClimateEntity,
	"lock": LockEntity,
	"text": TextEntity,
	"input_text": TextEntity,
	"date": DateTimeEntity,
	"time": DateTimeEntity,
	"datetime": DateTimeEntity,
	"cover": CoverEntity,
	"fan": FanEntity,
	"vacuum": VacuumEntity,
	"alarm_control_panel": AlarmEntity,
	"humidifier": HumidifierEntity,
	"water_heater": WaterHeaterEntity,
	"sun": SunEntity,
	"zone": ZoneEntity,
	"update": UpdateEntity,
	"event": EventEntity,
	"image": ImageEntity,
	"air_quality": AirQualityEntity,
	"calendar": CalendarEntity,
	"todo": TodoEntity,
	# Not a Home Assistant domain: the history chart of a sensor
	"line_chart": LineGraphEntity,
}

const ICONS = {
	"switch": "toggle_on",
	"input_boolean": "toggle_on",
	"automation": "smart_toy",
	"light": "lightbulb",
	"sensor": "sensors",
	"counter": "tag",
	"binary_sensor": "sensors",
	"media_player": "play_circle",
	"camera": "photo_camera",
	"button": "radio_button_checked",
	"input_button": "radio_button_checked",
	"scene": "palette",
	"script": "code",
	"number": "sliders",
	"input_number": "sliders",
	"line_chart": "finance",
	"timer": "timer",
	"weather": "partly_cloudy_day",
	"select": "list",
	"input_select": "list",
	"climate": "thermostat",
	"lock": "lock",
	"text": "text_fields",
	"input_text": "text_fields",
	"date": "calendar_today",
	"time": "schedule",
	"datetime": "event",
	"cover": "blinds",
	"fan": "mode_fan",
	"vacuum": "cleaning_services",
	"alarm_control_panel": "shield",
	"humidifier": "humidity_percentage",
	"water_heater": "water_heater",
	"sun": "wb_sunny",
	"zone": "location_on",
	"update": "system_update",
	"event": "event",
	"image": "image",
	"air_quality": "air",
	"calendar": "calendar_month",
	"todo": "checklist",
}

## Home Assistant domains that create_entity can turn into an entity widget.
static var SUPPORTED_DOMAINS: Array = SCENES.keys().filter(func(domain): return domain != "line_chart")

## Returns true if entities of this domain (or an entity id like "light.kitchen") can be placed.
static func is_supported(domain_or_id: String) -> bool:
	return SUPPORTED_DOMAINS.has(domain_or_id.split(".")[0])

static func create_entity(id: String, type=null):
	if type == null:
		type = id.split(".")[0]

	if not SCENES.has(type):
		return null

	var entity = SCENES[type].instantiate()
	entity.entity_id = id
	return entity

static func get_entity_icon(type: String) -> String:
	return ICONS.get(type, "question_mark")
