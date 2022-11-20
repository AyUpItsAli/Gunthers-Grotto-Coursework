class_name PlayerNoActionState
extends PlayerState

func handle_input(event):
	if player.main_state_machine.is_state("Dead"): return
	if player.main_state_machine.is_state("ExitCave"): return
	
	if event.is_action_pressed("equip_pickaxe"):
		PlayerData.equip(PlayerData.Tools.PICKAXE)
	elif event.is_action_pressed("equip_revolver"):
		PlayerData.equip(PlayerData.Tools.REVOLVER)
	elif event.is_action_pressed("equip_dynamite"):
		PlayerData.equip(PlayerData.Tools.DYNAMITE)
	elif event.is_action_pressed("use_tool"):
		state_machine.enter_state("UseTool")
	elif event.is_action_pressed("interact"):
		state_machine.enter_state("Interact")
