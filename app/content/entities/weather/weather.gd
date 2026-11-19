extends Entity

const Entity = preload ("../entity.gd")

@onready var animation: AnimatedSprite3D = $AnimatedSprite3D
@onready var weather_label: Label3D = $WeatherLabel
@onready var temp_label: Label3D = $TempLabel
@onready var humid_label: Label3D = $HumidLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	var stateInfo = await HomeApi.get_state(entity_id)

	set_state(stateInfo)

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

func set_state(stateInfo):
	if stateInfo == null:
		return

	var state = stateInfo["state"]
	var attributes = stateInfo["attributes"]

	# Missing values must replace the placeholder text from the scene.
	if attributes.get("temperature") != null:
		temp_label.text = str(attributes["temperature"]) + " " + str(attributes.get("temperature_unit", "")).strip_edges()
	else:
		temp_label.text = "–"

	if attributes.get("humidity") != null:
		humid_label.text = str(attributes["humidity"]) + "%"
	else:
		humid_label.text = "–"

	match state:
		"unavailable", "unknown":
			weather_label.text = state.capitalize()
			animation.play("code-red")
		"clear-night":
			weather_label.text = "Clear Night"
			animation.play("clear-night")
		"cloudy":
			weather_label.text = "Cloudy"
			animation.play("partly-cloudy-day")
		"fog":
			weather_label.text = "Fog"
			animation.play("fog")
		"hail":
			weather_label.text = "Hail"
			animation.play("hail")
		"lightning":
			weather_label.text = "Lightning"
			animation.play("thunderstorms")
		"lightning-rainy":
			weather_label.text = "Lightning Rainy"
			animation.play("thunderstorms-rain")
		"partlycloudy":
			weather_label.text = "Partly Cloudy"
			animation.play("partly-cloudy-day")
		"pouring":
			weather_label.text = "Pouring"
			animation.play("rain")
		"rainy":
			weather_label.text = "Rainy"
			animation.play("drizzle")
		"snowy":
			weather_label.text = "Snowy"
			animation.play("snow")
		"snowy-rainy":
			weather_label.text = "Snowy Rainy"
			animation.play("sleet")
		"sunny":
			weather_label.text = "Sunny"
			animation.play("clear-day")
		"windy":
			weather_label.text = "Windy"
			animation.play("wind")
		"windy-variant":
			weather_label.text = "Windy Variant"
			animation.play("wind")
		"exceptional":
			weather_label.text = "Exceptional"
			animation.play("code-red")
		_:
			weather_label.text = str(state).capitalize()
