extends StaticBody2D

# Called when the player's mining hurtbox detects the stalagmite
func on_player_mine(pos: Vector2) -> bool:
	queue_free()
	return true

# Called when an explosion detects the stalagmite
func on_explosion(pos: Vector2):
	queue_free()
