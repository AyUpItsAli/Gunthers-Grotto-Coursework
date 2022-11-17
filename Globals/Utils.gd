extends Node

func _ready():
	randomize()

# Takes in a float from 0 to 100 representing a percentage chance
# Returns whether the chance was successful or not
# Uses the specified random number generator, if given
func percent_chance(chance: float, rng: RandomNumberGenerator = null) -> bool:
	return rng.randf_range(0, 99) < chance if rng else rand_range(0, 99) < chance

# Returns a random element from the given array
# Uses the specified random number generator, if given
func choose_from(array: Array, rng: RandomNumberGenerator = null):
	return array[rng.randi() % array.size()] if rng else array[randi() % array.size()]

# Approximates the given vector in 4 directions:
# RIGHT, DOWN, LEFT and UP
func approximate_direction_4_ways(direction: Vector2) -> Vector2:
	var section = get_8_way_section(direction.rotated(-PI/8))
	match section:
		7,0: return Vector2.RIGHT
		1,2: return Vector2.DOWN
		3,4: return Vector2.LEFT
		5,6: return Vector2.UP
	return Vector2.ZERO

# Approximates the given vector in 8 directions:
# RIGHT, RIGHT+DOWN, DOWN, LEFT+DOWN, LEFT, LEFT+UP, UP and RIGHT+UP
func approximate_direction_8_ways(direction: Vector2) -> Vector2:
	var section = get_8_way_section(direction)
	match section:
		0: return Vector2.RIGHT
		1: return Vector2(1, 1) # RIGHT+DOWN
		2: return Vector2.DOWN
		3: return Vector2(-1, 1) # LEFT+DOWN
		4: return Vector2.LEFT
		5: return Vector2(-1, -1) # LEFT+UP
		6: return Vector2.UP
		7: return Vector2(1, -1) # RIGHT+UP
	return Vector2.ZERO

# For a circle split into 8 sections,
# this function returns an integer from 0 to 7 (inclusive),
# that represents the section of the circle the given direction lies within:
# 0 = RIGHT, 7 = RIGHT+UP
func get_8_way_section(direction: Vector2) -> int:
	if direction == Vector2.ZERO: return -1
	var section = stepify(direction.angle(), PI/4) / (PI/4)
	return wrapi(section, 0, 8)
