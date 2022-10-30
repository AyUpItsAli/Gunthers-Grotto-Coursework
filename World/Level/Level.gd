extends Node2D

# Node references
onready var ground = $World/Ground
onready var walls = $World/Walls
onready var objects = $World/Objects
onready var ceiling = $World/Ceiling

# HUD
onready var minimap = $HUD/UI/Minimap
onready var loading_screen = $HUD/LoadingScreen
onready var level_title = $HUD/UI/LevelTitle

func _ready():
	generate_level() # Generate a new level when this scene is loaded

func _process(delta):
	if objects.player_exists():
		var player_pos = objects.get_player().position
		minimap.update_player_pos(player_pos, ceiling)

# Generates a new level
func generate_level():
	# Ensure the loading screen is visible and fully opaque
	loading_screen.visible = true
	loading_screen.color.a = 1
	
	# Randomise the rng
	GameManager.rng.randomize()
	print("The cave seed is: " + str(GameManager.rng.get_seed()))
	
	walls.initialise_walls()
	var finished = walls.carry_out_generation()
	while not finished:
		# Continue algorithm until generation is finished
		finished = walls.carry_out_generation()
	walls.initialise_outside_border()
	walls.update_bitmask_region()
	
	# Update the ground layer to match the current walls tilemap
	ground.update_ground_layer()
	
	# Update the ceiling layer to match the current walls tilemap
	ceiling.update_ceiling_layer()
	ceiling.update_bitmask_region()
	
	# Update the minimap to match the current walls tilemap
	minimap.update_minimap(walls)
	
	# Spawn objects
	objects.clear_objects()
	objects.spawn_stalagmites()
	objects.spawn_gemstones()
	objects.spawn_player()
	objects.spawn_cave_exit()
	
	# Fade out the loading screen AFTER the level has finished generating
	var animations = loading_screen.get_node("LoadingScreenAnimations")
	animations.play("Fade_Out")
	yield(animations, "animation_finished")
	GameManager.increase_cave_depth()
	level_title.add_title_to_queue("Cave Depth\n" + str(GameManager.cave_depth))

# Called when the player enters the CaveExit detection radius
func on_player_exited_cave():
	if not loading_screen.visible:
		var animations = loading_screen.get_node("LoadingScreenAnimations")
		animations.play("Fade_In")
		yield(animations, "animation_finished")
		if GameManager.magie_level_should_spawn():
			get_tree().change_scene("res://World/MagpieLevel/MagpieLevel.tscn")
		else:
			generate_level()
