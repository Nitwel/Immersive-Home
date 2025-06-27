extends MeshInstance3D

@onready var anim_player = $"Compass Arrow/AnimationPlayer"
var active_target = null
var compass_active = false

func _ready() -> void:
		
	visible = compass_active
	if visible:
		anim_player.play("Appear")
	
	App.controller_left.get_node("Palm/QuickActions/Compass").on_toggled.connect(func(active):
		set_active(active)
	)
	App.menu.get_node("AnimationContainer/DebugTabsContent/ViewMenu/Content/Compass").on_toggled.connect(func(active):
		set_active(active)
	)
	
func _process(delta: float) -> void:
	if(active_target != null):
		look_at(active_target.position)
	
func set_active(active):
	compass_active = active
	if compass_active and active_target != null:
		anim_player.play("Appear")
		
	elif compass_active == false and visible:
		anim_player.play_backwards("Appear")
		
		

func set_target(target):
	active_target = target
	if target != null:
		if compass_active and visible == false:
			anim_player.play("Appear")
	else:
		anim_player.play_backwards("Appear")
	
