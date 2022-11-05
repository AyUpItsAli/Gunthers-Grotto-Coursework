class_name RockHermitHiddenState
extends RockHermitState

const TEXTURE_HIDDEN = preload("res://Assets/World/Stalagmite.png")

func enter(ctx: Dictionary = {}):
	enemy.body_sprite.texture = TEXTURE_HIDDEN
	enemy.target = null

func physics_update(delta):
	var bodies = enemy.detection_radius.get_overlapping_bodies()
	if bodies.size() > 0:
		var body = bodies[0]
		enemy.target_ray.cast_to = body.position - enemy.position
		enemy.target_ray.force_raycast_update()
		if !enemy.target_ray.is_colliding():
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
