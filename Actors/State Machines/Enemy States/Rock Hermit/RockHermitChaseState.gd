class_name RockHermitChaseState
extends RockHermitState

const TEXTURE_RIGHT = preload("res://Assets/Actors/Enemies/Rock_Hermit_Right.png")
const TEXTURE_LEFT = preload("res://Assets/Actors/Enemies/Rock_Hermit_Left.png")
const MOVE_SPEED = 3000

func enter(ctx: Dictionary = {}):
	if not ctx.has("target"): return state_machine.enter_state("Hidden")
	enemy.target = ctx["target"]
	chase_target()

func update(delta):
	update_sprite()
	enemy.hurtbox.look_at(enemy.target.position)

func update_sprite():
	if enemy.target.position.x > enemy.position.x:
		enemy.body_sprite.texture = TEXTURE_RIGHT
	elif enemy.target.position.x < enemy.position.x:
		enemy.body_sprite.texture = TEXTURE_LEFT
	elif enemy.body_sprite.texture != TEXTURE_RIGHT and enemy.body_sprite.texture != TEXTURE_LEFT:
		randomize()
		enemy.body_sprite.texture = TEXTURE_RIGHT if randf() < 0.5 else TEXTURE_LEFT

func physics_update(delta):
	var new_velocity = enemy.direction * MOVE_SPEED * delta
	enemy.velocity = enemy.move_and_slide(new_velocity)

func chase_target():
	enemy.line_of_sight.cast_to = enemy.target.position - enemy.position
	enemy.line_of_sight.force_raycast_update()
	
	if !enemy.line_of_sight.is_colliding():
		enemy.direction = enemy.line_of_sight.cast_to.normalized()
		return
	else:
		for player_scent in enemy.target.scent_trail:
			enemy.line_of_sight.cast_to = player_scent.position - enemy.position
			enemy.line_of_sight.force_raycast_update()
			
			if !enemy.line_of_sight.is_colliding():
				enemy.direction = enemy.line_of_sight.cast_to.normalized()
				return
	enemy.direction = Vector2.ZERO

func take_damage(attacker, damage: int):
	enemy.body_sprite.modulate = Color.red
	enemy.health -= damage
	if enemy.health < 0: enemy.health = 0
	yield(get_tree().create_timer(0.1), "timeout")
	enemy.body_sprite.modulate = Color.white
	if enemy.health == 0:
		state_machine.enter_state("Dead")
