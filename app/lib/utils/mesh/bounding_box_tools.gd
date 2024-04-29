static func get_bounding_box_2d(points) -> Rect2:
	if points.size() == 0:
		return Rect2()

	var min_x = points[0].x
	var min_y = points[0].y
	var max_x = points[0].x
	var max_y = points[0].y

	for i in range(1, points.size()):
		min_x = min(min_x, points[i].x)
		min_y = min(min_y, points[i].y)
		max_x = max(max_x, points[i].x)
		max_y = max(max_y, points[i].y)

	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

static func resize_bounding_box_2d(bbox: Rect2, target_box: Rect2) -> Transform2D:
	var scale = Vector2(target_box.size.x / bbox.size.x, target_box.size.y / bbox.size.y)
	var offset = target_box.get_center() - bbox.get_center()

	return Transform2D(0, scale, 0, offset)