extends Node

func _ready():
	randomize()

# Takes in a float from 0 to 100 representing a percentage chance
# Returns whether the chance was successful or not
# Uses the specified random number generator, if given
func percent_chance(chance: float, rng: RandomNumberGenerator = null) -> bool:
	return rng.randf_range(0, 99) < chance if rng else rand_range(0, 99) < chance

# Returns a random element from the given array
func choose_from(array: Array):
	return array[randi() % array.size()]

# Approximates the given direction vector
# Returns either LEFT, RIGHT, UP or DOWN
func approximate_direction(direction: Vector2):
	if abs(direction.x) > abs(direction.y):
		return Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	else:
		return Vector2.UP if direction.y < 0 else Vector2.DOWN
