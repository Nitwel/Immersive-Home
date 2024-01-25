extends StaticBody3D

@export var entity_id = "camera.bedroomspeaker"
@export var view_width = 0.15

@onready var view = $View
@onready var http_request = $HTTPRequest
@onready var mesh = $MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready():
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
		load_image(stateInfo["attributes"]["entity_picture"])
		

func load_image(url: String):
	http_request.request("http://192.168.33.33:8123" + url)

	var result = await http_request.request_completed

	if result[0] != HTTPRequest.RESULT_SUCCESS:
		print("Error loading image: ", result[0], " ", result[1])
		return

	var image = Image.new()
	var error = image.load_png_from_buffer(result[3])

	var pixel_size = view_width / image.get_size().x

	if error != OK:
		print("Error loading image: ", error)
		return

	var texture = ImageTexture.create_from_image(image)
	view.texture = texture
	view.pixel_size = pixel_size
	mesh.visible = false