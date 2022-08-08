extends Node2D

# Node references
onready var ground_layer = $World/GroundLayer
onready var walls_layer = $World/WallsLayer
onready var rock_layer = $World/RockLayer

func _ready():
	generate_level() # Generate a new level when the scene is loaded

# Generates a new level
func generate_level():
	GameManager.rng.randomize() # Re-randomise the game's rng
	
	rock_layer.initialise_rock_layer()
	var finished = rock_layer.carry_out_generation()
	while not finished:
		# Continue algorithm until generation is finished
		finished = rock_layer.carry_out_generation()
	rock_layer.update_bitmask_region()
	
	# Update the ground layer to match the current rock layer
	ground_layer.update_ground_layer()
	
	# Update the walls layer to match the current rock layer
	walls_layer.update_walls_layer()
