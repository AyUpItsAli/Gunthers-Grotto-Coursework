class_name RockHermitState
extends State

var enemy: RockHermit

# Called by the state machine when initialising states
func init(_state_machine):
	enemy = owner as RockHermit
	.init(_state_machine)
