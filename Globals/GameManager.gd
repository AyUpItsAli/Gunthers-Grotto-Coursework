extends Node

# Minimum and maximum number of caves between visiting the magpie level
const MIN_CAVES_BETWEEN_MAGPIE = 3
const MAX_CAVES_BETWEEN_MAGPIE = 10
# Chance for the magpie level to spawn
const MAGPIE_CHANCE = 15

# Random number generator specific to the current cave seed
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

func reset_game_data():
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
	return Utils.percent_chance(MAGPIE_CHANCE)

# Creates a pool of items from the given dictionary of item frequencies
func create_pool(frequencies: Dictionary) -> Array:
	var pool = []
	for item in frequencies: # For each item...
		var n = frequencies[item] # Store the frequency of this item as "n"
		for i in range(n):
			pool.append(item) # Add this item to the pool, n times
	return pool

# Returns whether the chance was successful or not
# Uses rng corresponding to the current cave seed
func percent_chance(chance: float) -> bool:
	return Utils.percent_chance(chance, rng)

# Returns a random element from the given array
# Uses rng corresponding to the current cave seed
func choose_from(array: Array):
	return Utils.choose_from(array, rng)

# Picks a random entry from the given pool
func random_pool_entry(pool: Array):
	return Utils.choose_from(pool)
