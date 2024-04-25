@tool
extends FlexContainer3D
class_name Pagination3D

signal on_page_changed(page: int)

const ButtonScene = preload ("res://content/ui/components/button/button.tscn")
const LabelScene = preload ("res://content/ui/components/label_container/label_container.tscn")

const ButtonMaterial = preload ("button.material")
const ButtonActiveMaterial = preload ("button_active.material")

@onready var prev_button = $Prev
@onready var next_button = $Next

@export var page: int = 0:
	set(value):
		if page == value: return

		page = clamp(value, 0, pages - 1)
		_update()
@export var pages: int = 5:
	set(value):
		if pages == value: return

		pages = max(1, value)
		_update()
@export var visible_pages: int = 5:
	set(value):
		if visible_pages == value: return

		visible_pages = max(5, value)
		_update()

func _ready():
	_update()

	prev_button.on_button_up.connect(func():
		page -= 1
		on_page_changed.emit(page)
	)

	next_button.on_button_up.connect(func():
		page += 1
		on_page_changed.emit(page)
	)

func _update():
	if !is_node_ready(): return

	for child in get_children():
		if child != prev_button&&child != next_button:
			remove_child(child)
			child.queue_free()

	var display_pages = min(pages, visible_pages)
	var center_pos = floor(display_pages / 2)
	var start_dots = pages > visible_pages&&page > visible_pages - center_pos - 1
	var end_dots = pages > visible_pages&&page < pages - visible_pages + floor((display_pages - 1) / 2)

	var at_start = page == 0
	prev_button.disabled = at_start
	prev_button.visible = !at_start

	var at_end = page == pages - 1
	next_button.disabled = at_end
	next_button.visible = !at_end

	prev_button.size = Vector3(size.y, size.y, size.z)
	next_button.size = Vector3(size.y, size.y, size.z)

	for i in range(display_pages):
		if (start_dots&&i == 1)||(end_dots&&i == display_pages - 2):
			var container = Container3D.new()
			container.size = Vector3(size.y, size.y, size.z)
			add_child(container)
			move_child(container, -2)

			var dots = LabelScene.instantiate()
			dots.text = "..."
			container.add_child(dots)
			continue
		
		var button = ButtonScene.instantiate()
		button.size = Vector3(size.y, size.y, size.z)

		if i == 0:
			button.label = "1"
		elif i == display_pages - 1:
			button.label = str(pages)
		elif pages <= visible_pages:
			button.label = str(i + 1)
		elif visible_pages % 2 == 1:
			button.label = str(clamp(page, center_pos, pages - 1 - center_pos) - center_pos + i + 1)
		else:
			button.label = str(clamp(page + 1, 3, pages - 3) - center_pos + i + 1)

		button.on_button_up.connect(func():
			page=int(button.label) - 1
			on_page_changed.emit(page)
		)

		add_child(button)
		move_child(button, -2)

		button.get_node("Body/MeshInstance3D").material_override = ButtonActiveMaterial if (int(button.label) - 1) == page else ButtonMaterial

	super._update()
	