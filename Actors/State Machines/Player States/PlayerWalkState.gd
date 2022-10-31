class_name PlayerWalkState
extends PlayerState

func update(delta):
	player.rotate_hurtboxes()
	player.determine_facing()
	if player.action_state_machine.is_state("NoAction"):
		match player.facing:
			Vector2.UP: player.animations.play("Walk_Up")
			Vector2.RIGHT: player.animations.play("Walk_Right")
			Vector2.LEFT: player.animations.play("Walk_Left")
			_: player.animations.play("Walk_Down")

func physics_update(delta):
	var intended_velocity = player.get_intended_velocity(delta)
	player.velocity = player.move_and_slide(intended_velocity)
	if intended_velocity == Vector2.ZERO:
		state_machine.enter_state("Idle")
