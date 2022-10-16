extends YSort

func player_exists() -> bool:
	return has_node("Player")

func get_player():
	return get_node("Player")
