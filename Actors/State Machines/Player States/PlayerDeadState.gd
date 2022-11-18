class_name PlayerDeadState
extends PlayerState

const WAIT_TIME_AFTER_DEATH = 5

func enter(ctx: Dictionary = {}):
	# Stop animations and hide sprites
	player.animations.stop()
	player.body_sprite.visible = false
	player.item_sprite.visible = false
	# Clear scent trail
	player.clear_scent_trail()
	# Pause after dying, then load the game over screen
	yield(get_tree().create_timer(WAIT_TIME_AFTER_DEATH), "timeout")
	Loading.change_scene("res://GUI/GameOverScreen/GameOverScreen.tscn")
