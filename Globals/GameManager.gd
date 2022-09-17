extends Node

# Random number generator used throughout the game
onready var rng := RandomNumberGenerator.new()

func percent_chance(chance: float) -> bool:
	return rng.randf_range(0, 99) < chance

# Creates a pool of items from the given dictionary of item frequencies
func create_pool(frequencies: Dictionary) -> Array:
	var pool = []
	for item in frequencies: # For each item...
		var n = frequencies[item] # Store the frequency of this item (n)
		for i in range(n):
			pool.append(item) # Add this item to the pool, n times
	return pool

# Chooses an item from the given pool
func choose_from(pool: Array):
	return pool[randi() % pool.size()]
