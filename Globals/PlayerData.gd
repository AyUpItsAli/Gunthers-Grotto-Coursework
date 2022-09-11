extends Node

var health = 5

func reduce_health(amount: int):
	health -= amount
	if health <= 0:
		health = 0
		print("Game Over")
