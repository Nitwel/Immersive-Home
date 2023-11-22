extends Function
class_name Clickable

signal on_click(event: EventRay)
signal on_press_down(event: EventRay)
signal on_press_move(event: EventRay)
signal on_press_up(event: EventRay)
signal on_grab_down(event: EventRay)
signal on_grab_move(event: EventRay)
signal on_grab_up(event: EventRay)
signal on_ray_enter(event: EventRay)
signal on_ray_leave(event: EventRay)

func _on_click(event: EventRay):
	on_click.emit(event)

func _on_press_down(event: EventRay):
	on_press_down.emit(event)

func _on_press_move(event: EventRay):
	on_press_move.emit(event)

func _on_press_up(event: EventRay):
	on_press_up.emit(event)

func _on_grab_down(event: EventRay):
	on_grab_down.emit(event)

func _on_grab_move(event: EventRay):
	on_grab_move.emit(event)

func _on_grab_up(event: EventRay):
	on_grab_up.emit(event)

func _on_ray_enter(event: EventRay):
	on_ray_enter.emit(event)

func _on_ray_leave(event: EventRay):
	on_ray_leave.emit(event)