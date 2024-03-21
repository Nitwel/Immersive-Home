@tool

extends Node3D
class_name Button3D

signal on_button_down()
signal on_button_up()

const IconFont = preload ("res://assets/icons/icons.tres")
const ECHO_WAIT_INITIAL = 0.5
const ECHO_WAIT_REPEAT = 0.1

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
		if !is_node_ready(): await ready
		label_node.font_size = value
@export var label: String = "":
	set(value):
		label = value
		if !is_node_ready(): await ready
		label_node.text = value
@export var icon: bool = false:
	set(value):
		icon = value
		if !is_node_ready(): await ready

		if value:
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
var external_value: Proxy = null:
	set(value):
		external_value = value
		if !is_node_ready(): await ready

		if value != null:
			value.on_set.connect(func(_value):
				update_animation()
			)

var active: bool = false:
	get:
		if external_value != null:
			return external_value.value
		return active
	set(value):
		if !is_node_ready(): await ready

		if external_value != null:
			external_value.value = value
		else:
			active = value
		update_animation()

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var echo_timer: Timer = null

func _ready():
	if initial_active:
		active = true

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

func update_animation():
	var length = animation_player.get_animation("down").length

	if animation_player.current_animation == "":
		return

	if active&&animation_player.current_animation_position != length:
		animation_player.play("down")
	elif !active&&animation_player.current_animation_position != 0:
		animation_player.play_backwards("down")
		
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

	animation_player.stop()
	animation_player.speed_scale = 0
	animation_player.current_animation = "down"
	AudioPlayer.play_effect("click")
	_touch_change(event)

func _on_touch_move(event: EventTouch):
	_touch_change(event)

func _on_touch_leave(_event: EventTouch):
	animation_player.stop()
	animation_player.speed_scale = 1

	if toggleable:
		active = !active
		if active:
			on_button_up.emit()
		else:
			on_button_down.emit()

func _touch_change(event: EventTouch):
	if disabled:
		event.bubbling = false
		return

	var pos = Vector3(0, 1, 0)
	for finger in event.fingers:
		var finger_pos = to_local(finger.area.global_position)
		if pos.y > finger_pos.y:
			pos = finger_pos

	var button_height = 0.2
	var button_center = 0.1

	var percent = clamp((button_center + button_height / 2 - pos.y) / (button_height / 2), 0, 1)

	if !active&&percent < 1:
		on_button_down.emit()
	elif active&&percent >= 1:
		on_button_up.emit()
		
	animation_player.seek(percent * animation_player.current_animation_length, true)

	if toggleable:
		return
	
	active = percent < 1
