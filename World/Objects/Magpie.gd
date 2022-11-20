extends StaticBody2D

# Called when the player interacts with the magpie
func on_player_interact():
	if PlayerData.remove_item(Globals.Items.GEM):
		var bullet_reward = GameManager.random_pool_entry(
			GameManager.bullet_reward_pool)
		var dynamite_reward = GameManager.random_pool_entry(
			GameManager.dynamite_reward_pool)
		PlayerData.add_item(Globals.Items.REVOLVER_AMMO, bullet_reward)
		PlayerData.add_item(Globals.Items.DYNAMITE_STICK, dynamite_reward)
