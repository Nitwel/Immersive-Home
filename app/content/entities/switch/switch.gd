extends Entity

const Entity = preload ("../entity.gd")

@onready var sprite: AnimatedSprite3D = $Icon
@onready var snap_sound = $SnapSound

var active = R.state(false)
var available = true

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
	available = stateInfo["state"] != "unavailable"&&stateInfo["state"] != "unknown"
	# Only "on" and "off" have a toggle icon; anything else would be an unknown icon name.
	icon.value = "toggle_on" if active.value else "toggle_off"
	# Fade an unavailable switch so it doesn't look like it's simply off.
	sprite.modulate.a = 1.0 if available else 0.3

func _on_click(_event):
	if not available:
		return
	snap_sound.play()
	_toggle()

func quick_action():
	_toggle()

func _toggle():
	HomeApi.set_state(entity_id, "off" if active.value else "on")