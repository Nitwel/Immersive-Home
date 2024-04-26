@tool
extends FlexContainer3D

signal on_select()

@onready var button = $Button
@onready var label = $LabelContainer

@export var icon: String = "question_mark":
	set(value):
		icon = value
		_update()

@export var text: String = "Button":
	set(value):
		text = value
		_update()

func _ready():
	super._ready()

	button.on_button_up.connect(func():
		on_select.emit()
	)

func _update():
	if !is_node_ready(): return

	button.label = icon
	label.text = text

	super._update()
