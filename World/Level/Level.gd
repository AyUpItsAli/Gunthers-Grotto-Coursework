extends Node2D

# Node references
onready var ground_layer = $World/GroundLayer
onready var walls_layer = $World/WallsLayer
onready var rock_layer = $World/RockLayer
onready var objects = $World/Objects

func _ready():
	generate_level() # Generate a new level when the scene is loaded

# Generates a new level
func generate_level():
	# Randomise the rng
	GameManager.rng.randomize()
	# Initialise the gem quantity pool
	Globals.gem_quantity_pool = GameManager.create_pool(Globals.GEM_FREQUENCIES)
	
	rock_layer.initialise_rock_layer()
	var finished = rock_layer.carry_out_generation()
	while not finished:
		# Continue algorithm until generation is finished
		finished = rock_layer.carry_out_generation()
	rock_layer.initialise_outside_border()
	rock_layer.update_bitmask_region()
	
	# Update the ground layer to match the current rock layer
	ground_layer.update_ground_layer()
	
	# Update the walls layer to match the current rock layer
	walls_layer.update_walls_layer()
	
	# Spawn objects
	objects.spawn_stalagmites()
	objects.spawn_gemstones()
	objects.spawn_player()
