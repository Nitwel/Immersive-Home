extends Entity
## fan: power button, speed (percentage) slider, preset mode and oscillation.
## Rows for features the fan doesn't support are left out and the card shrinks.

const Entity = preload ("../entity.gd")
const UI = preload ("../entity_ui.gd")

const WIDTH = 0.24
## Top edge of the card; rows are stacked downwards from here.
const TOP = 0.08

## FanEntityFeature flags
const FEATURE_SET_SPEED = 1
const FEATURE_OSCILLATE = 2
const FEATURE_PRESET_MODE = 8

var panel: Panel3D
var type_icon: Label3D
var name_label: Label3D
var power_button: Button3D
var speed_label: Label3D
var speed_slider: Slider3D
var preset_select: Select3D
var oscillate_button: Button3D

var state := "unknown"
var oscillating := false

var _applying_state = false

func _ready():
	super()
	icon.value = "mode_fan"

	panel = UI.card(self, Vector2(WIDTH, 0.15))
	type_icon = UI.label(self, "mode_fan", 22, Vector3(-WIDTH / 2 + 0.02, TOP - 0.02, 0), HORIZONTAL_ALIGNMENT_CENTER, true)
	name_label = UI.label(self, entity_id, 22, Vector3(-WIDTH / 2 + 0.034, TOP - 0.02, 0))
	power_button = UI.icon_button(self, "power_settings_new", Vector3(WIDTH / 2 - 0.022, TOP - 0.022, 0), 0.03)
	speed_label = UI.label(self, "", 36, Vector3(0, TOP - 0.06, 0), HORIZONTAL_ALIGNMENT_CENTER)
	speed_slider = UI.slider(self, Vector3.ZERO, WIDTH - 0.03)
	preset_select = UI.select(self, Vector3.ZERO, WIDTH - 0.024)
	preset_select.sort_options = false
	oscillate_button = UI.icon_button(self, "sync", Vector3.ZERO, 0.03)

	power_button.on_button_up.connect(_toggle)
	speed_slider.on_value_changed.connect(func(value):
		HomeApi.set_state(entity_id, "percentage", {"percentage": int(value)})
	)
	preset_select.on_select.connect(func(mode):
		if _applying_state or mode == null:
			return
		HomeApi.set_state(entity_id, "preset_mode", {"preset_mode": mode})
	)
	oscillate_button.on_button_up.connect(func():
		HomeApi.set_state(entity_id, "oscillate", {"oscillating": not oscillating})
	)

	set_state(await HomeApi.get_state(entity_id))

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

func set_state(state_info):
	if state_info == null:
		return

	state = str(state_info["state"])
	var attributes = UI.attributes_of(state_info)
	var available = not UI.is_unavailable(state)
	var is_on = state == "on"

	# Leave room for the power button on the right.
	UI.fit_label(name_label, UI.entity_name(entity_id, attributes), WIDTH - 0.084)
	# mode_fan_off renders with MSDF artefacts in the icon font, so dim the fan instead.
	type_icon.modulate = Color(1, 1, 1, 1.0 if is_on else 0.5)

	var percentage = attributes.get("percentage")
	var presets = attributes.get("preset_modes")
	if not presets is Array:
		presets = []
	oscillating = attributes.get("oscillating") == true

	var fallback = (FEATURE_SET_SPEED if percentage != null else 0) \
		| (FEATURE_OSCILLATE if attributes.has("oscillating") else 0) \
		| (FEATURE_PRESET_MODE if not presets.is_empty() else 0)
	var features = UI.features_of(attributes, fallback)
	var has_speed = (features & FEATURE_SET_SPEED) != 0
	var has_presets = (features & FEATURE_PRESET_MODE) != 0 and not presets.is_empty()
	var has_oscillate = (features & FEATURE_OSCILLATE) != 0

	if not available:
		speed_label.text = state.capitalize()
	elif is_on and percentage != null and has_speed:
		speed_label.text = "%d %%" % int(percentage)
	else:
		speed_label.text = "On" if is_on else "Off"

	power_button.active = is_on
	power_button.disabled = not available
	UI.dim_button(power_button, not available)

	_applying_state = true
	if attributes.get("percentage_step") != null and float(attributes["percentage_step"]) > 0:
		speed_slider.step = float(attributes["percentage_step"])
	if percentage != null:
		speed_slider.value = float(percentage)

	var options = {}
	for mode in presets:
		options[str(mode)] = str(mode).capitalize()
	if preset_select.options != options:
		preset_select.options = options
	preset_select.selected = UI.option_or_null(options, str(attributes.get("preset_mode")))
	_applying_state = false

	oscillate_button.active = oscillating
	oscillate_button.disabled = not available
	UI.dim_button(oscillate_button, not available)

	_layout(has_speed, has_presets, has_oscillate)

## Stacks the optional rows below the speed label and fits the card around them.
func _layout(has_speed: bool, has_presets: bool, has_oscillate: bool):
	var y = TOP - 0.085

	UI.set_shown(speed_slider, has_speed)
	if has_speed:
		speed_slider.position = Vector3(0, y - 0.015, 0)
		y -= 0.035

	UI.set_shown(preset_select, has_presets)
	UI.set_shown(oscillate_button, has_oscillate)
	if has_presets or has_oscillate:
		var select_width = WIDTH - 0.024 - (0.038 if has_oscillate else 0.0)
		preset_select.size = Vector3(select_width, 0.03, 0.01)
		preset_select.position = Vector3(-WIDTH / 2 + 0.012 + select_width / 2, y - 0.02, 0)
		oscillate_button.position = Vector3(WIDTH / 2 - 0.027 if has_presets else 0.0, y - 0.02, 0)
		y -= 0.04

	var height = TOP - y + 0.008
	UI.resize_card(self, panel, Vector2(WIDTH, height), TOP - height / 2)

func _toggle():
	if UI.is_unavailable(state):
		return
	HomeApi.set_state(entity_id, "off" if state == "on" else "on")

func quick_action():
	_toggle()
