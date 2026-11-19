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
			if slider.get_parent() == null:
				add_child(slider)
		elif slider.get_parent() == self:
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
	# Players don't always report every attribute (e.g. no title for a stream)
	var attributes = stateInfo.get("attributes", {})
	if attributes == null:
		attributes = {}

	# Update the media info in every state: a paused player still has a track loaded,
	# and an idle/off one has none, which must clear the previous (or placeholder) info.
	# entity_picture_local only exists when entity_picture points to an outside
	# address; otherwise entity_picture already is the Home Assistant proxy path.
	var picture = attributes.get("entity_picture_local")
	if picture == null:
		picture = attributes.get("entity_picture")
	if picture != null:
		load_image(str(picture))
	else:
		_clear_image()

	if attributes.get("media_title") != null:
		title.text = str(attributes["media_title"])
		artist.text = str(attributes["media_artist"]) if attributes.get("media_artist") != null else ""
	else:
		title.text = str(attributes["friendly_name"]) if attributes.get("friendly_name") != null else entity_id
		artist.text = str(state).capitalize()

	if attributes.get("volume_level") != null:
		volume = float(attributes["volume_level"]) * 100
		slider.value = volume

	if state == "playing":
		playing = true
		play.label = "pause"
		icon.value = "play_circle"
	else:
		playing = false
		play.label = "play_arrow"
		icon.value = "pause_circle"

var _image_url = ""

func _clear_image():
	if _image_url == "" and logo.texture == null:
		return
	_image_url = ""
	http_request.cancel_request()
	logo.texture = null

func load_image(url: String):
	if url.begins_with("/"):
		url = HomeApi.get_http_url() + url

	# State updates arrive often while playing; only fetch when the cover changes
	if url == _image_url:
		return
	_image_url = url

	http_request.cancel_request()
	http_request.request(url)

	var result = await http_request.request_completed

	if url != _image_url:
		return # a newer cover was requested meanwhile

	if result[0] != HTTPRequest.RESULT_SUCCESS||result[1] != 200:
		print("Error loading image: ", result[0], " ", result[1])
		_image_url = ""
		return

	var image = Image.new()
	var error = image.load_jpg_from_buffer(result[3])
	if error != OK:
		error = image.load_png_from_buffer(result[3])
	if error != OK:
		error = image.load_webp_from_buffer(result[3])

	if error != OK||image.get_size().x == 0:
		print("Error loading image: ", error)
		_image_url = ""
		return

	var texture = ImageTexture.create_from_image(image)
	logo.texture = texture
	logo.pixel_size = image_width / image.get_size().x

func get_options():
	return {
		"show_volume": show_volume.value,
		"show_image": show_image.value
	}

func set_options(options):
	if options.has("show_volume"): show_volume.value = options["show_volume"]
	if options.has("show_image"): show_image.value = options["show_image"]