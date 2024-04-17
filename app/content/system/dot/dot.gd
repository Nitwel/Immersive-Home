extends StaticBody3D

const Entity = preload ("res://content/entities/entity.gd")

@export var entity: Entity

@onready var collision = $CollisionShape3D
@onready var label = $Label3D
var active = R.state(false)
var disabled = R.state(true)

var miniature = House.body.mini_view

func _ready():
	R.effect(func(_arg):
		label.text=entity.icon.value
		label.modulate=entity.icon_color.value
	)

	# Update active
	R.effect(func(_arg):
		label.outline_modulate=Color(242 / 255.0, 90 / 255.0, 56 / 255.0, 1) if active.value else Color(0, 0, 0, 1)
	)

	# Update disabled
	R.effect(func(_arg):
		visible=!disabled.value
		collision.disabled=disabled.value
	)

func _on_click(_event: EventPointer):
	if entity.has_method("quick_action"):
		entity.quick_action()
	else:
		miniature.entity_select.toggle(entity)

func _on_move_start(_event: EventPointer):
	miniature.entity_select.toggle(entity)