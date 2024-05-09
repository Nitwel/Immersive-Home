extends Entity

const Entity = preload ("../entity.gd")

@onready var sprite: AnimatedSprite3D = $Icon
@onready var snap_sound = $SnapSound

var active = R.state(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	var stateInfo = await HomeApi.get_state(entity_id)

	set_state(stateInfo)

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

	R.effect(func(_arg):
		sprite.set_frame(1 if active.value else 0)
	)

func set_state(stateInfo):
	if stateInfo == null:
		return

	active.value = stateInfo["state"] == "on"
	icon.value = "toggle_" + stateInfo["state"]

func _on_click(_event):
	snap_sound.play()
	_toggle()

func quick_action():
	_toggle()

func _toggle():
	HomeApi.set_state(entity_id, "off" if active.value else "on")