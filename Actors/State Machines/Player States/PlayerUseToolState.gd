class_name PlayerUseToolState
extends PlayerState

const PICKAXE_DAMAGE = 1
const BULLET = preload("res://Actors/Player/Bullet.tscn")
const DYNAMITE = preload("res://Actors/Player/Dynamite.tscn")

func enter(ctx: Dictionary = {}):
	if PlayerData.equipped_tool == PlayerData.Tools.PICKAXE and player.pickaxe_cooldown.is_stopped():
		swing_pickaxe()
		yield(player.animations, "animation_finished")
		player.pickaxe_cooldown.start()
	elif PlayerData.equipped_tool == PlayerData.Tools.REVOLVER and player.revolver_cooldown.is_stopped():
		fire_revolver()
		player.revolver_cooldown.start()
	elif PlayerData.equipped_tool == PlayerData.Tools.DYNAMITE and player.dynamite_cooldown.is_stopped():
		throw_dynamite()
		player.update_item_sprite() # Update item sprite in case this was the last dynamite to be thrown
		player.dynamite_cooldown.start()
	state_machine.enter_state("NoAction")

func swing_pickaxe():
	match player.facing:
		Vector2.UP: player.animations.play("Melee_Up")
		Vector2.RIGHT: player.animations.play("Melee_Right")
		Vector2.LEFT: player.animations.play("Melee_Left")
		_: player.animations.play("Melee_Down")
	damage_enemies_and_mine_objects()
	player.emit_signal("pickaxe_used")

# Damages hitbox owners and mines objects overlapping with the player's hurtbox
func damage_enemies_and_mine_objects():
	for area in player.hurtbox.get_overlapping_areas():
		var node = area.get_parent()
		if node.has_method("take_damage"):
			node.take_damage(player, PICKAXE_DAMAGE)
	for body in player.hurtbox.get_overlapping_bodies():
		if body.has_method("on_player_mine"):
			body.on_player_mine()

func fire_revolver():
	if PlayerData.remove_item(Globals.Items.REVOLVER_AMMO):
		var clicked_pos = player.get_global_mouse_position()
		var bullet = BULLET.instance()
		bullet.player = player
		bullet.position = player.position
		bullet.velocity = player.position.direction_to(clicked_pos)
		bullet.look_at(clicked_pos)
		get_parent().add_child(bullet)

func throw_dynamite():
	if PlayerData.remove_item(Globals.Items.DYNAMITE_STICK):
		var clicked_pos = player.get_global_mouse_position()
		var dynamite = DYNAMITE.instance()
		dynamite.player = player
		dynamite.position = player.position
		dynamite.destination = clicked_pos
		dynamite.rotation_degrees = rand_range(0, 360)
		get_parent().add_child(dynamite)
