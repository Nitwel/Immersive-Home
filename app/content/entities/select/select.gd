extends Entity
## select / input_select: a dropdown with the entity's options.

const Entity = preload ("../entity.gd")
const UI = preload ("../entity_ui.gd")

const WIDTH = 0.22
const HEIGHT = 0.08

var name_label: Label3D
var dropdown: Select3D

## Set while the dropdown is updated from Home Assistant; Select3D emits on_select
## for programmatic changes too, which must not be sent back as a service call.
var _applying_state = false

func _ready():
	super()
	icon.value = "list"

	UI.card(self, Vector2(WIDTH, HEIGHT))
	name_label = UI.label(self, entity_id, 22, Vector3(-WIDTH / 2 + 0.012, HEIGHT / 2 - 0.018, 0))
	dropdown = UI.select(self, Vector3(0, -0.012, 0), WIDTH - 0.024)
	dropdown.sort_options = false # keep Home Assistant's order (low, medium, high)
	dropdown.on_select.connect(_on_select)

	set_state(await HomeApi.get_state(entity_id))

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

func set_state(state_info):
	if state_info == null:
		return

	var state = str(state_info["state"])
	var attributes = UI.attributes_of(state_info)

	name_label.text = UI.entity_name(entity_id, attributes)

	_applying_state = true
	var options = {}
	var list = attributes.get("options")
	if list is Array:
		for option in list:
			options[str(option)] = str(option)
	if dropdown.options != options:
		dropdown.options = options
	dropdown.selected = state if options.has(state) else null
	_applying_state = false

func _on_select(option):
	if _applying_state||option == null:
		return
	HomeApi.set_state(entity_id, option)
