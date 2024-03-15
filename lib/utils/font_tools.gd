static func get_font_size(label: Label3D, chars=null):
	var font = label.font

	if font == null:
		return Vector2(0, 0)

	var size = font.get_string_size(label.text if chars == null else chars, label.horizontal_alignment, label.width, label.font_size) * label.pixel_size

	return size