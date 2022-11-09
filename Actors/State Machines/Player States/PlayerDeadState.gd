class_name PlayerDeadState
extends PlayerState

const WAIT_TIME_AFTER_DEATH = 5

func enter(ctx: Dictionary = {}):
	# Stop animations and hide sprites
	player.animations.stop()
	player.body_sprite.visible = false
	player.item_sprite.visible = false
	# Clear scent trail
	for scent in player.scent_trail:
		scent.queue_free()
	player.scent_trail.clear()
	# Pause after dying, then load the game over screen
	yield(get_tree().create_timer(WAIT_TIME_AFTER_DEATH), "timeout")
	LoadingScreen.change_scene("res://GUI/GameOverScreen/GameOverScreen.tscn")
