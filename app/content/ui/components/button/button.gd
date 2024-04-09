@tool

extends Node3D
class_name Button3D

signal on_button_down()
signal on_button_up()
signal on_toggled(active: bool)

const IconFont = preload ("res://assets/icons/icons.tres")
const ECHO_WAIT_INITIAL = 0.5
const ECHO_WAIT_REPEAT = 0.1

@onready var body: StaticBody3D = $Body
@onready var label_node: Label3D = $Body/Label
@onready var finger_area: Area3D = $FingerArea

@export var focusable: bool = true:
	set(value):
		focusable = value
		if value == false:
			add_to_group("ui_focus_stop")
		else:
			remove_from_group("ui_focus_stop")

@export var font_size: int = 10:
	set(value):
		font_size = value
		if !is_inside_tree()||icon: return
		label_node.font_size = font_size

@export var label: String = "":
	set(value):
		label = value
		if !is_inside_tree(): return
		label_node.text = label

@export var icon: bool = false:
	set(value):
		icon = value
		if !is_inside_tree(): return
		
		if icon:
			label_node.font = IconFont
			label_node.font_size = 36
			label_node.width = 1000
			label_node.autowrap_mode = TextServer.AUTOWRAP_OFF
		else:
			label_node.font = null
			label_node.font_size = font_size
			label_node.width = 50
			label_node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

@export var toggleable: bool = false
@export var disabled: bool = false
@export var echo: bool = false
@export var initial_active: bool = false

var active: bool = false:
	set(value):
		if active != value:
			on_toggled.emit(value)
		active = value
		if !is_inside_tree(): return
		update_animation(1.0 if active else 0.0)
	
var echo_timer: Timer = null

func _ready():
	if initial_active:
		active = true

	Update.props(self, ["active", "external_value", "icon", "label", "font_size"])

	if echo:
		echo_timer = Timer.new()
		echo_timer.wait_time = ECHO_WAIT_INITIAL
		echo_timer.one_shot = false

		echo_timer.timeout.connect(func():
			echo_timer.stop()
			echo_timer.wait_time=ECHO_WAIT_REPEAT
			echo_timer.start()
			on_button_down.emit()
		)

		add_child(echo_timer)

func update_animation(value: float):
	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(body, "scale:y", lerpf(1.0, 0.5, value), 0.2)
	tween.tween_property(body, "position:y", lerpf(0.01, 0.005, value), 0.2)
		
func _on_press_down(event):
	if disabled:
		event.bubbling = false
		return

	AudioPlayer.play_effect("click")

	if toggleable:
		return

	if echo:
		echo_timer.start()

	active = true
	on_button_down.emit()
	
func _on_press_up(event):
	if disabled:
		event.bubbling = false
		return

	if toggleable:
		active = !active

		if active:
			on_button_down.emit()
		else:
			on_button_up.emit()
	else:
		if echo:
			echo_timer.stop()
			echo_timer.wait_time = ECHO_WAIT_INITIAL

		active = false
		on_button_up.emit()

func _on_touch_enter(event: EventTouch):
	if event.target != finger_area:
		return

	if disabled:
		event.bubbling = false
		return

	AudioPlayer.play_effect("click")

	if toggleable:
		active = !active
		if active:
			on_button_down.emit()
		else:
			on_button_up.emit()

		return

	active = true
	on_button_down.emit()

	_touch_change(event)

func _on_touch_move(event: EventTouch):
	if disabled:
		event.bubbling = false
		return

	if toggleable:
		return

	_touch_change(event)

func _on_touch_leave(event: EventTouch):
	if disabled:
		event.bubbling = false
		return

	if toggleable:
		return

	active = false
	on_button_up.emit()

func _touch_change(event: EventTouch):

	var pos = Vector3(0, 1, 0)
	for finger in event.fingers:
		var finger_pos = to_local(finger.area.global_position)
		if pos.y > finger_pos.y:
			pos = finger_pos

	var button_height = 0.2
	var button_center = 0.1

	var percent = clamp((button_center + button_height / 2 - pos.y) / (button_height / 2), 0, 1)
		
	update_animation(percent)
