class_name RockHermitDeadState
extends RockHermitState

func enter(ctx: Dictionary = {}):
	enemy.queue_free()
