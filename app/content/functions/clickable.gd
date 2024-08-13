extends Function
class_name Clickable

signal on_click(event: EventPointer)
signal on_press_down(event: EventPointer)
signal on_press_move(event: EventPointer)
signal on_press_up(event: EventPointer)
signal on_grab_down(event: EventPointer)
signal on_grab_move(event: EventPointer)
signal on_grab_up(event: EventPointer)
signal on_ray_enter(event: EventPointer)
signal on_ray_leave(event: EventPointer)

func _on_click(event: EventPointer):
	on_click.emit(event)

func _on_press_down(event: EventPointer):
	on_press_down.emit(event)

func _on_press_move(event: EventPointer):
	on_press_move.emit(event)

func _on_press_up(event: EventPointer):
	on_press_up.emit(event)

func _on_grab_down(event: EventPointer):
	on_grab_down.emit(event)

func _on_grab_move(event: EventPointer):
	on_grab_move.emit(event)

func _on_grab_up(event: EventPointer):
	on_grab_up.emit(event)

func _on_ray_enter(event: EventPointer):
	on_ray_enter.emit(event)

func _on_ray_leave(event: EventPointer):
	on_ray_leave.emit(event)
