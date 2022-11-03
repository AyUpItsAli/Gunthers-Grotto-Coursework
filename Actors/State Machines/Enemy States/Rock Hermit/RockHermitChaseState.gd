class_name RockHermitChaseState
extends RockHermitState

const TEXTURE_RIGHT = preload("res://Assets/Actors/Enemies/Rock_Hermit_Right.png")
const TEXTURE_LEFT = preload("res://Assets/Actors/Enemies/Rock_Hermit_Left.png")
const MAX_SPEED = 3000
const MAX_STEERING = 3

func enter(ctx: Dictionary = {}):
	if not ctx.has("target"): return state_machine.enter_state("Hidden")
	enemy.target = ctx["target"]
	var target_pos = get_target_pos()
	enemy.agent.set_target_location(target_pos)

func update(delta):
	update_sprite()
	enemy.hurtbox.look_at(enemy.target.position)
	
#	if enemy.velocity.is_equal_approx(Vector2.ZERO):
#		get_tree().create_timer(1).connect("timeout", self, "check")

#func check():
#	if enemy.velocity.is_equal_approx(Vector2.ZERO):
#		state_machine.enter_state("Hidden")

func update_sprite():
	if enemy.target.position.x > enemy.position.x:
		enemy.body_sprite.texture = TEXTURE_RIGHT
	elif enemy.target.position.x < enemy.position.x:
		enemy.body_sprite.texture = TEXTURE_LEFT
	elif enemy.body_sprite.texture != TEXTURE_RIGHT and enemy.body_sprite.texture != TEXTURE_LEFT:
		randomize()
		enemy.body_sprite.texture = TEXTURE_RIGHT if randf() < 0.5 else TEXTURE_LEFT

#func physics_update(delta):
#	var steering = get_seek_steering(delta)
#	steering = steering.clamped(MAX_STEERING)
#
#	enemy.velocity += steering
#	enemy.velocity = enemy.velocity.clamped(MAX_SPEED)
#
#	enemy.debug_ray.rotation = enemy.velocity.angle()
#	enemy.debug_ray.cast_to.x = enemy.velocity.length()
#
#	enemy.velocity = enemy.move_and_slide(enemy.velocity)
#
#func get_seek_steering(delta) -> Vector2:
#	var desired_velocity = get_seek_direction() * MAX_SPEED * delta
#	return desired_velocity - enemy.velocity

func physics_update(delta):
	var target_pos = get_target_pos()
	enemy.agent.set_target_location(target_pos)
	var next_pos = enemy.agent.get_next_location()
	enemy.velocity = enemy.position.direction_to(next_pos) * MAX_SPEED * delta
	enemy.agent.set_velocity(enemy.velocity)

func get_target_pos() -> Vector2:
	enemy.target_ray.cast_to = enemy.target.position - enemy.position
	enemy.target_ray.force_raycast_update()
	
	if !enemy.target_ray.is_colliding():
		return enemy.target.position
	else:
		for player_scent in enemy.target.scent_trail:
			enemy.target_ray.cast_to = player_scent.position - enemy.position
			enemy.target_ray.force_raycast_update()
			
			if !enemy.target_ray.is_colliding():
				return player_scent.position
	
	# TODO:
	# If didn't find new target, default to whatever is the current target
	
	return enemy.position

#func get_seek_direction() -> Vector2:
#	enemy.target_ray.cast_to = enemy.target.position - enemy.position
#	enemy.target_ray.force_raycast_update()
#
#	if !enemy.target_ray.is_colliding():
#		return enemy.target_ray.cast_to.normalized()
#	else:
#		for player_scent in enemy.target.scent_trail:
#			enemy.target_ray.cast_to = player_scent.position - enemy.position
#			enemy.target_ray.force_raycast_update()
#
#			if !enemy.target_ray.is_colliding():
#				return enemy.target_ray.cast_to.normalized()
#
#	return Vector2.ZERO

#func get_avoidance_steering(delta) -> Vector2:
#	enemy.avoidance_rays.rotation = enemy.velocity.angle()
#
#	for raycast in enemy.avoidance_rays.get_children():
#		raycast.cast_to.x = enemy.velocity.length()
#		if raycast.is_colliding():
#			var collider = raycast.get_collider()
#			var pos = collider.position
#			if collider is TileMap:
#				return Vector2.ZERO
#				var collision_point = raycast.get_collision_point()
#				var tile_pos = collider.world_to_map(collision_point)
#				pos = collider.map_to_world(tile_pos) + Vector2(16, 16)
#			var avoid_direction = enemy.position + enemy.velocity - pos
#			return avoid_direction.normalized() * AVOID_FORCE
#
#	return Vector2.ZERO

func take_damage(attacker, damage: int):
	enemy.body_sprite.modulate = Color.red
	enemy.health -= damage
	if enemy.health < 0: enemy.health = 0
	yield(get_tree().create_timer(0.1), "timeout")
	enemy.body_sprite.modulate = Color.white
	if enemy.health == 0:
		state_machine.enter_state("Dead")
