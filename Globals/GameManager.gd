extends Node

# Random number generator used throughout the game
onready var rng := RandomNumberGenerator.new()

func percent_chance(chance: float) -> bool:
	return rng.randf_range(0, 99) < chance
