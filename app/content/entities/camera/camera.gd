extends Entity

const Entity = preload ("../entity.gd")

@export var view_width = 0.15

@onready var view = $View
@onready var http_request = $HTTPRequest
@onready var mesh = $MeshInstance3D
@onready var refresh_timer = $RefreshTimer

var cam_active = R.state(false)
var cam_fps = R.state(10)

# Called when the node enters the scene tree for the first time.
func _ready():
	super()

	R.effect(func(_arg):
		refresh_timer.wait_time=1.0 / cam_fps.value
	)

	R.effect(func(_arg):
		if cam_active.value:
			refresh_timer.start()
		else:
			refresh_timer.stop()
	)

	icon.value = "photo_camera"

	var stateInfo = await HomeApi.get_state(entity_id)

	set_state(stateInfo)

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

func set_state(stateInfo):
	if stateInfo == null:
		view.texture = null
		mesh.visible = true
		return

	var state = stateInfo["state"]

	if state == "unavailable":
		view.texture = null
		mesh.visible = true
		return

	if stateInfo["attributes"].has("entity_picture"):
		var url = stateInfo["attributes"]["entity_picture"]
		load_image(url)
		refresh_timer.timeout.disconnect(load_image.bind(url))
		refresh_timer.timeout.connect(load_image.bind(url))

func load_image(url: String):
	http_request.request("http://192.168.33.33:8123" + url)

	var result = await http_request.request_completed

	if result[0] != HTTPRequest.RESULT_SUCCESS:
		print("Error loading image: ", result[0], " ", result[1])
		return

	var headers = Array(result[2]).reduce(func(acc, header):
		var pair=header.split(":")
		acc[pair[0]]=pair[1].trim_prefix(" ").trim_suffix(" ")
		return acc
	, {})

	var content_type = headers["Content-Type"] if headers.has("Content-Type") else "image/png"

	var image = Image.new()
	var error

	match content_type:
		"image/png":
			error = image.load_png_from_buffer(result[3])
		"image/jpeg":
			error = image.load_jpg_from_buffer(result[3])
		"image/gif":
			error = image.load_gif_from_buffer(result[3])
		"image/bmp":
			error = image.load_bmp_from_buffer(result[3])
		"image/webp":
			error = image.load_webp_from_buffer(result[3])
		_:
			print("Unsupported content type: ", content_type, " for image: ", url)
			cam_active.value = false
			return

	if error != OK:
		print("Error loading image: ", error)
		return

	var pixel_size = view_width / image.get_size().x

	var texture = ImageTexture.create_from_image(image)
	view.texture = texture
	view.pixel_size = pixel_size
	mesh.visible = false