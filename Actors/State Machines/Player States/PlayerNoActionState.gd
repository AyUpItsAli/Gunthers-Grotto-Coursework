class_name PlayerNoActionState
extends PlayerState

func handle_input(event):
	if player.main_state_machine.is_state("Dead"): return
	
	if event.is_action_pressed("equip_pickaxe"):
		player.equip(player.Tools.PICKAXE)
	elif event.is_action_pressed("equip_revolver"):
		player.equip(player.Tools.REVOLVER)
	elif event.is_action_pressed("equip_dynamite"):
		player.equip(player.Tools.DYNAMITE)
	elif event.is_action_pressed("use_tool"):
		state_machine.enter_state("UseTool")
	elif event.is_action_pressed("interact"):
		state_machine.enter_state("Interact")
