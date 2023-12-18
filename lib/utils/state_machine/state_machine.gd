class_name StateMachine
extends Node

signal changed(state_name: String, old_state: String)

@export var current_state: Node
var states: Dictionary = {}

func _ready() -> void:
	for state in get_children():
		states[state.get_name()] = state
		state.state_machine = self

		if state != current_state:
			remove_child(state)

	await get_parent().ready
		
	current_state._on_enter()

func change_to(new_state: String) -> void:
	if states.has(new_state) == false:
		return

	var old_state = current_state.get_name()

	current_state._on_leave()
	remove_child(current_state)
	current_state = states[new_state]
	add_child(current_state)
	current_state._on_enter()
	changed.emit(new_state, old_state)