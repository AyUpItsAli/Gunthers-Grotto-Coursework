extends StaticBody2D

func on_player_mine(pos) -> bool:
	queue_free()
	return true
