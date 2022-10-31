class_name PlayerDeadState
extends PlayerState

const WAIT_TIME_AFTER_DEATH = 5

func enter(ctx: Dictionary = {}):
	player.animations.stop()
	player.body_sprite.visible = false
	player.item_sprite.visible = false
	player.clear_scent_trail()
	yield(get_tree().create_timer(WAIT_TIME_AFTER_DEATH), "timeout")
	get_tree().change_scene("res://GUI/GameOverScreen/GameOverScreen.tscn")
