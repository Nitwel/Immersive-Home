extends Function
class_name Clickable

signal on_click(event: Dictionary)
signal on_press_down(event: Dictionary)
signal on_press_move(event: Dictionary)
signal on_press_up(event: Dictionary)
signal on_grab_down(event: Dictionary)
signal on_grab_move(event: Dictionary)
signal on_grab_up(event: Dictionary)
signal on_ray_enter(event: Dictionary)
signal on_ray_leave(event: Dictionary)

func _on_click(event: Dictionary):
	on_click.emit(event)

func _on_press_down(event: Dictionary):
	on_press_down.emit(event)

func _on_press_move(event: Dictionary):
	on_press_move.emit(event)

func _on_press_up(event: Dictionary):
	on_press_up.emit(event)

func _on_grab_down(event: Dictionary):
	on_grab_down.emit(event)

func _on_grab_move(event: Dictionary):
	on_grab_move.emit(event)

func _on_grab_up(event: Dictionary):
	on_grab_up.emit(event)

func _on_ray_enter(event: Dictionary):
	on_ray_enter.emit(event)

func _on_ray_leave(event: Dictionary):
	on_ray_leave.emit(event)