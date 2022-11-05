class_name PlayerWalkState
extends PlayerState

const MOVE_SPEED = 5000
const PLAYER_SCENT = preload("res://Actors/Player/PlayerScent.tscn")

func update(delta):
	player.determine_facing()
	var mouse_pos = player.get_global_mouse_position()
	player.hurtbox.look_at(mouse_pos)
	if player.action_state_machine.is_state("NoAction"):
		match player.facing:
			Vector2.UP: player.animations.play("Walk_Up")
			Vector2.RIGHT: player.animations.play("Walk_Right")
			Vector2.LEFT: player.animations.play("Walk_Left")
			_: player.animations.play("Walk_Down")

func physics_update(delta):
	var intended_velocity = Vector2.ZERO
	intended_velocity.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	intended_velocity.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	# Normalize the vector then multiply by movement speed and delta time 
	intended_velocity = intended_velocity.normalized() * MOVE_SPEED * delta
	# Move the player via their velocity vector
	player.velocity = player.move_and_slide(intended_velocity)
	# If the player is not moving, switch to idle state
	if player.velocity == Vector2.ZERO:
		state_machine.enter_state("Idle")

# Reduces the player's health and triggers death state
func take_damage(attacker, damage: int):
	player.body_sprite.modulate = Color.red
	var survived = PlayerData.reduce_health(damage)
	yield(get_tree().create_timer(0.1), "timeout")
	player.body_sprite.modulate = Color.white
	if not survived:
		state_machine.enter_state("Dead")

# Spawns player scent at the player's current position
func leave_scent():
	var scent = PLAYER_SCENT.instance()
	scent.player = player
	scent.position = player.position
	player.get_parent().add_child(scent)
	player.scent_trail.push_front(scent)
