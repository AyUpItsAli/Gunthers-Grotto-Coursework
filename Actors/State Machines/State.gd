class_name State
extends Node

var state_machine: StateMachine

# Called by the state machine when initialising
func init(_state_machine):
	state_machine = _state_machine

func enter(ctx: Dictionary = {}):
	pass

func handle_input(event: InputEvent):
	pass

func update(delta):
	pass

func physics_update(delta):
	pass

func exit():
	pass
