extends Node

# Random number generator used throughout the game
onready var rng := RandomNumberGenerator.new()

# A pool of gem quantities generated from Globals.GEM_FREQUENCIES
onready var gem_quantity_pool = create_pool(Globals.GEM_FREQUENCIES)

# Creates a pool of items from the given dictionary of item frequencies
func create_pool(frequencies: Dictionary) -> Array:
	var pool = []
	for item in frequencies: # For each item...
		var n = frequencies[item] # Store the frequency of this item as "n"
		for i in range(n):
			pool.append(item) # Add this item to the pool, n times
	return pool

# Takes in a float from 0 to 100 representing a percentage chance
# Returns whether the chance was successful or not
func percent_chance(chance: float) -> bool:
	return rng.randf_range(0, 99) < chance

# Picks a random item from the gem quantity pool
func get_random_gem_quantity() -> int:
	return gem_quantity_pool[randi() % gem_quantity_pool.size()]
