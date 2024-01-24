extends Node3D
class_name TabsContent3D

@export var tabs: Tabs3D

var children: Array = []

func _ready():
	children = get_children()

	for child in children:
		child.visible = true
		if tabs.selected != null && tabs.selected.get_index() == child.get_index():
			continue
		remove_child(child)

	tabs.on_select.connect(func(index):
		for child in get_children():
			remove_child(child)

		add_child(children[index])
	)
