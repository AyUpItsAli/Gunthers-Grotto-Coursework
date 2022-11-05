class_name PlayerUseToolState
extends PlayerState

const PICKAXE_DAMAGE = 1
const BULLET = preload("res://Actors/Player/Bullet.tscn")
const DYNAMITE = preload("res://Actors/Player/Dynamite.tscn")

func enter(ctx: Dictionary = {}):
	if player.equipped == player.Tools.PICKAXE and player.pickaxe_cooldown.is_stopped():
		use_pickaxe()
		yield(player.animations, "animation_finished")
		player.pickaxe_cooldown.start()
	elif player.equipped == player.Tools.REVOLVER and player.revolver_cooldown.is_stopped():
		use_revolver()
		player.revolver_cooldown.start()
	elif player.equipped == player.Tools.DYNAMITE and player.dynamite_cooldown.is_stopped():
		use_dynamite()
		player.dynamite_cooldown.start()
	state_machine.enter_state("NoAction")

func use_pickaxe():
	match player.facing:
		Vector2.UP: player.animations.play("Melee_Up")
		Vector2.RIGHT: player.animations.play("Melee_Right")
		Vector2.LEFT: player.animations.play("Melee_Left")
		_: player.animations.play("Melee_Down")
	damage_enemies_with_pickaxe()
	player.emit_signal("pickaxe_used")

# Calls the "take_damage" method
# on all hitboxes overlapping the attacking hurtbox
func damage_enemies_with_pickaxe():
	for area in player.attacking_hurtbox.get_overlapping_areas():
		var node = area.get_parent()
		if node.has_method("take_damage"):
			node.take_damage(player, PICKAXE_DAMAGE)

func use_revolver():
	if PlayerData.remove_item(Globals.ItemIDs.REVOLVER_AMMO):
		var clicked_pos = player.get_global_mouse_position()
		var bullet = BULLET.instance()
		bullet.player = player
		bullet.position = player.position
		bullet.velocity = player.position.direction_to(clicked_pos)
		bullet.look_at(clicked_pos)
		get_parent().add_child(bullet)

func use_dynamite():
	if PlayerData.remove_item(Globals.ItemIDs.DYNAMITE_STICK):
		var clicked_pos = player.get_global_mouse_position()
		var dynamite = DYNAMITE.instance()
		dynamite.player = player
		dynamite.position = player.position
		dynamite.destination = clicked_pos
		dynamite.rotation_degrees = rand_range(0, 360)
		get_parent().add_child(dynamite)
