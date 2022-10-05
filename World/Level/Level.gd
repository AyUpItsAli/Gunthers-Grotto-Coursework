extends Node2D

# Node references
onready var ground_layer = $World/GroundLayer
onready var walls_layer = $World/WallsLayer
onready var rock_layer = $World/RockLayer
onready var objects = $World/Objects

# HUD
onready var minimap = $HUD/UI/Minimap
onready var loading_screen = $HUD/LoadingScreen
onready var cave_depth_title = $HUD/UI/CaveDepthTitle

# Objects
onready var cave_exit = $World/Objects/CaveExit

func _ready():
	cave_exit.connect("player_entered", self, "on_player_exited_cave")
	generate_level() # Generate a new level when this scene is loaded

func _process(delta):
	if objects.player_exists():
		var player_pos = objects.get_player().position
		var player_tile_pos = ground_layer.world_to_map(player_pos)
		minimap.update_player_pos(player_tile_pos)

# Generates a new level
func generate_level():
	# Randomise the rng
	GameManager.rng.randomize()
	
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
	
	# Update the minimap to match the current rock layer
	minimap.update_minimap(rock_layer)
	
	# Spawn objects
	objects.clear_objects()
	objects.spawn_stalagmites()
	objects.spawn_gemstones()
	#objects.spawn_player() Disable random player spawning while testing
	
	# Fade out the loading screen AFTER the level has finished generating
	if loading_screen.visible:
		var animations = loading_screen.get_node("LoadingScreenAnimations")
		animations.play("Fade_Out")
		yield(animations, "animation_finished")
		GameManager.increase_cave_depth()
		cave_depth_title.add_depth_to_queue(GameManager.cave_depth)

# Called when the player enters the CaveExit detection radius
func on_player_exited_cave():
	if not loading_screen.visible:
		var animations = loading_screen.get_node("LoadingScreenAnimations")
		animations.play("Fade_In")
		yield(animations, "animation_finished")
		generate_level()
