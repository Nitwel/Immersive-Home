# Global event bus
extends Node

# Interaction Events
signal on_click(event: Dictionary)
signal on_press_down(event: Dictionary)
signal on_press_move(event: Dictionary)
signal on_press_up(event: Dictionary)
signal on_grab_down(event: Dictionary)
signal on_grab_move(event: Dictionary)
signal on_grab_up(event: Dictionary)
signal on_ray_enter(event: Dictionary)
signal on_ray_leave(event: Dictionary)