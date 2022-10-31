class_name PlayerIdleState
extends PlayerState

func update(delta):
	player.rotate_hurtboxes()
	player.determine_facing()
	if player.action_state_machine.is_state("NoAction"):
		match player.facing:
			Vector2.UP: player.animations.play("Idle_Up")
			Vector2.RIGHT: player.animations.play("Idle_Right")
			Vector2.LEFT: player.animations.play("Idle_Left")
			_: player.animations.play("Idle_Down")
	
	var intended_velocity = Vector2.ZERO
	intended_velocity.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	intended_velocity.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	# If the player should move, switch to idle state
	if intended_velocity != Vector2.ZERO:
		state_machine.enter_state("Walk")

# Reduces the player's health and triggers death state
func take_damage(damage: int):
	player.body_sprite.modulate = Color.red
	var survived = PlayerData.reduce_health(damage)
	yield(get_tree().create_timer(0.1), "timeout")
	player.body_sprite.modulate = Color.white
	if not survived: state_machine.enter_state("Dead")
