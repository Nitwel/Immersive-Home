extends Entity

const Entity = preload ("../entity.gd")

@export var image_width = 0.15

@onready var previous = $Previous
@onready var next = $Next
@onready var play = $Play
@onready var logo = $PlayingInfo/Logo
@onready var title = $PlayingInfo/Title
@onready var artist = $PlayingInfo/Artist
@onready var http_request = $PlayingInfo/HTTPRequest
@onready var slider = $Slider
@onready var settings = $Settings

var playing = false
var volume = 50

var show_volume = R.state(true)
var show_image = R.state(true)

# Called when the node enters the scene tree for the first time.
func _ready():
	super()

	remove_child(settings)

	R.effect(func(_arg):
		if show_settings.value:
			add_child(settings)
		elif settings.is_inside_tree():
			remove_child(settings)
			camera_follower.reset()
			App.house.save_all_entities()
	)

	R.effect(func(_arg):
		if show_volume.value:
			add_child(slider)
		else:
			remove_child(slider)
	)

	R.effect(func(_arg):
		logo.visible=show_image.value
	)

	icon.value = "pause_circle"

	var stateInfo = await HomeApi.get_state(entity_id)
	set_state(stateInfo)

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

	previous.on_button_down.connect(func():
		HomeApi.set_state(entity_id, "previous")
	)

	play.on_button_down.connect(func():
		if playing:
			HomeApi.set_state(entity_id, "pause")
		else:
			HomeApi.set_state(entity_id, "play")
	)

	next.on_button_down.connect(func():
		HomeApi.set_state(entity_id, "next")
	)

	slider.on_value_changed.connect(set_volume)

func set_volume(value):
	volume = value
	HomeApi.set_state(entity_id, "volume", {"volume_level": value / 100})

func set_state(stateInfo):
	if stateInfo == null:
		return

	var state = stateInfo["state"]

	if state == "playing":
		if stateInfo["attributes"].has("entity_picture_local"):
			load_image(stateInfo["attributes"]["entity_picture_local"])
		title.text = stateInfo["attributes"]["media_title"]
		artist.text = stateInfo["attributes"]["media_artist"]

		volume = float(stateInfo["attributes"]["volume_level"]) * 100
		slider.value = volume
		
		playing = true
		play.label = "pause"
		icon.value = "play_circle"
	else:
		playing = false
		play.label = "play_arrow"
		icon.value = "pause_circle"

func load_image(url: String):
	http_request.request("http://192.168.33.33:8123" + url)

	var result = await http_request.request_completed

	if result[0] != HTTPRequest.RESULT_SUCCESS:
		print("Error loading image: ", result[0], " ", result[1])
		return

	var image = Image.new()
	var error = image.load_jpg_from_buffer(result[3])

	var pixel_size = image_width / image.get_size().x

	if error != OK:
		print("Error loading image: ", error)
		return

	var texture = ImageTexture.create_from_image(image)
	logo.texture = texture
	logo.pixel_size = pixel_size

func get_options():
	return {
		"show_volume": show_volume.value,
		"show_image": show_image.value
	}

func set_options(options):
	if options.has("show_volume"): show_volume.value = options["show_volume"]
	if options.has("show_image"): show_image.value = options["show_image"]