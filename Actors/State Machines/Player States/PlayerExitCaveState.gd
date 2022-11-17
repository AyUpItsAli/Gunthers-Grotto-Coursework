class_name PlayerExitCaveState
extends PlayerState

# Base amount of time (in seconds) for the player to move towards the cave exit
const BASE_MOVE_DURATION = 0.5
# Amount of time (in seconds) for the player to fade / disappear
const FADE_DURATION = 1
# Amount of time (in seconds) to wait after the player has disappeared
const WAIT_TIME_AFTER_CAVE_EXIT = 0.5

func enter(ctx: Dictionary = {}):
	if not ctx.has("exit_pos"): return state_machine.enter_previous_state()
	var exit_pos = ctx.get("exit_pos")
	# Clear player scent trail
	player.clear_scent_trail()
	# Face towards the cave exit and play walking animation
	player.set_facing_towards(player.position.direction_to(exit_pos))
	match player.facing:
		Vector2.UP: player.animations.play("Walk_Up")
		Vector2.RIGHT: player.animations.play("Walk_Right")
		Vector2.LEFT: player.animations.play("Walk_Left")
		_: player.animations.play("Walk_Down")
	# Move player towards the centre of the cave exit
	# and decrease their opacity to 0, via a tween
	var tween = player.create_tween()
	var move_duration = BASE_MOVE_DURATION * (player.position.distance_to(exit_pos) / 25)
	tween.tween_property(player, "position", exit_pos, move_duration)
	tween.tween_property(player, "modulate", Color(1, 1, 1, 0), FADE_DURATION)
	# Wait for tween to finish
	yield(tween, "finished")
	# Wait an extra few seconds,
	# then signal the level node that the player has exited the cave
	yield(get_tree().create_timer(WAIT_TIME_AFTER_CAVE_EXIT), "timeout")
	player.emit_signal("exited_cave")
