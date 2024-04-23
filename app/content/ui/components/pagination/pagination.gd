@tool
extends FlexContainer3D

const ButtonScene = preload ("res://content/ui/components/button/button.tscn")

@onready var prev_button = $Prev
@onready var next_button = $Next

@export var page: int = 0:
	set(value):
		page = clamp(value, 0, pages - 1)

		if !is_inside_tree(): return

		_update()
@export var pages: int = 5:
	set(value):
		pages = max(1, value)
		
		if !is_inside_tree(): return

		_update()
@export var visible_pages: int = 5:
	set(value):
		visible_pages = max(1, value)

		if !is_inside_tree(): return

		_update()

func _ready():
	_update()

func _update():
	for child in get_children():
		if child != prev_button&&child != next_button:
			print("queue_free", child)
			child.queue_free()
			await child.tree_exited

	var display_pages = min(pages, visible_pages)
	var start_dots = pages > visible_pages&&page > visible_pages - 3
	var end_dots = pages > visible_pages&&page < pages - visible_pages + 2
	var center_pos = floor(display_pages / 2)

	prev_button.size = Vector3(size.y, size.y, size.z)

	for i in range(display_pages):
		if (start_dots&&i == 1)||(end_dots&&i == display_pages - 2):
			var dots = Label3D.new()
			dots.text = "..."
			add_child(dots)
			move_child(dots, -2)
			continue
		
		var button = ButtonScene.instantiate()
		button.size = Vector3(size.y, size.y, size.z)

		if i == 0:
			button.label = "1"
		elif i == display_pages - 1:
			button.label = str(pages)
		else:
			button.label = str(clamp(page - center_pos + i + 1, 2, pages - 2))

		button.on_button_up.connect(func(_arg):
			page=int(button.label) - 1
		)

		add_child(button)
		move_child(button, -2)

	super._update()
	