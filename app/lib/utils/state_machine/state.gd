extends Node
## Base Class for all states
class_name MachineState

var state_machine: StateMachine

func is_active():
	return state_machine.current_state == self

func _on_enter():
	pass

func _on_leave():
	pass