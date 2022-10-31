class_name PlayerState
extends State

var player: Player

# Called by the state machine when initialising states
func init(_state_machine):
	player = owner as Player
	.init(_state_machine)
