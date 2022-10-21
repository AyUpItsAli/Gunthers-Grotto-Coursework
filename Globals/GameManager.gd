extends Node

# Minimum and maximum number of caves between visiting the magpie level
const MIN_CAVES_BETWEEN_MAGPIE = 3
const MAX_CAVES_BETWEEN_MAGPIE = 10
# Chance for the magpie level to spawn
const MAGPIE_CHANCE = 15

# Random number generator used throughout the game
onready var rng := RandomNumberGenerator.new()

# A pool of gem quantities generated from Globals.GEM_FREQUENCIES
onready var gem_quantity_pool = create_pool(Globals.GEM_FREQUENCIES)

# Pools of bullet and dynamite quantities rewarded to the player
onready var bullet_reward_pool = create_pool(Globals.BULLET_REWARD_FREQUENCIES)
onready var dynamite_reward_pool = create_pool(Globals.DYNAMITE_REWARD_FREQUENCIES)

# Number of caves the player has visited
# This acts as the player's score
var cave_depth = 0

# Number of caves visited since the last time the magpie level spawned
var caves_since_magpie = 0

func reset_score():
	cave_depth = 0
	caves_since_magpie = 0

# Called whenever a cave is generated
func increase_cave_depth():
	cave_depth += 1
	caves_since_magpie += 1

# Returns whether the magpie level should spawn at this time
func magie_level_should_spawn() -> bool:
	if caves_since_magpie < MIN_CAVES_BETWEEN_MAGPIE: return false
	if caves_since_magpie >= MAX_CAVES_BETWEEN_MAGPIE: return true
	return percent_chance(MAGPIE_CHANCE)

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

# Picks a random entry from the given pool
func random_pool_entry(pool: Array):
	return pool[randi() % pool.size()]
