extends StaticBody2D

# Called when the player's hurtbox detects the stalagmite
func on_player_mine():
	queue_free()

# Called when an explosion detects the stalagmite
func on_explosion(pos: Vector2):
	queue_free()
