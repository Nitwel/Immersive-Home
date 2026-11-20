extends "../info_card.gd"
## image: a picture Home Assistant provides (e.g. a map, a doorbell snapshot or an
## AI generated image). Reloaded whenever the image changes (the state is its time).

const IMAGE_WIDTH = 0.2

var view := Sprite3D.new()
var placeholder: Label3D
var http_request := HTTPRequest.new()
var image_url := ""
var image_height := 0.0

func _init():
	card_width = 0.224

func _build():
	add_child(http_request)
	view.pixel_size = 0.001
	view.render_priority = 15
	add_child(view)
	placeholder = UI.label(self, "image", 48, Vector3.ZERO, HORIZONTAL_ALIGNMENT_CENTER, true)
	placeholder.modulate = Color(1, 1, 1, 0.4)

func _show(_state: String, attributes: Dictionary):
	icon.value = "image"
	value_label.text = ""
	# "unknown" only means the image never changed; the picture can still be there.
	detail_label.text = "Unavailable" if state == "unavailable" else ""

	var url = attributes.get("entity_picture")
	# The URL carries a rotating access token, so reload on every state change.
	image_url = str(url) if url != null and state != "unavailable" else ""
	if image_url == "":
		_set_texture(null)
	else:
		_load()

func _load():
	var url = image_url
	var texture = await UI.load_image(http_request, url)
	if url != image_url or not is_inside_tree():
		return
	_set_texture(texture)

func _set_texture(texture: Texture2D):
	view.texture = texture
	view.visible = texture != null
	placeholder.visible = texture == null
	if texture != null:
		view.pixel_size = IMAGE_WIDTH / texture.get_width()
		image_height = texture.get_height() * view.pixel_size
	else:
		image_height = 0.08
	_layout()

func _layout_extra(y: float) -> float:
	if view == null or placeholder == null:
		return y
	view.position = Vector3(0, y - 0.004 - image_height / 2, 0.001)
	placeholder.position = Vector3(0, y - 0.004 - image_height / 2, 0)
	return y - image_height - 0.006
