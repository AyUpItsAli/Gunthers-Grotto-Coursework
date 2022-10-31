class_name PlayerInteractState
extends PlayerState

func enter(ctx: Dictionary = {}):
	interact()
	state_machine.enter_state("NoAction")

# Calls the "on_player_interact" method on the first interactable object
# that is currently overlapping with the player's hitbox
func interact():
	var areas = player.hitbox.get_overlapping_areas()
	if areas.size() > 0:
		var object = areas[0].get_parent()
		if object.has_method("on_player_interact"):
			object.on_player_interact()
