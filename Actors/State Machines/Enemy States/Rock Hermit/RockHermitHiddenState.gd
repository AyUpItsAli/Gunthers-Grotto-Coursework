class_name RockHermitHiddenState
extends RockHermitState

const TEXTURE_HIDDEN = preload("res://Assets/World/Stalagmite.png")

func enter(ctx: Dictionary = {}):
	enemy.body_sprite.texture = TEXTURE_HIDDEN
	enemy.target = null
	# Check if player is within detection radius

func on_body_detected(body):
	state_machine.enter_state("Chase", {"target":body})

func take_damage(attacker, damage: int):
	enemy.body_sprite.modulate = Color.red
	enemy.health -= damage
	if enemy.health < 0: enemy.health = 0
	state_machine.enter_state("Chase", {"target":attacker})
	yield(get_tree().create_timer(0.1), "timeout")
	enemy.body_sprite.modulate = Color.white
	if enemy.health == 0:
		state_machine.enter_state("Dead")
