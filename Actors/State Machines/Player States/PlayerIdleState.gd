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
	
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
		state_machine.enter_state("Walk")
