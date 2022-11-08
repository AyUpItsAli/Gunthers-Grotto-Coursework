extends Node2D

# Node references
onready var world = $World
onready var ground = $World/Ground
onready var walls = $World/Walls
onready var objects = $World/Objects
onready var ceiling = $World/Ceiling
onready var mining_grid = $World/MiningGrid

# HUD
onready var minimap = $HUD/UI/Minimap
onready var level_title = $HUD/UI/LevelTitle

var generation_thread := Thread.new()

func _ready():
	generate_level()

func generate_level():
	if generation_thread.is_active(): return
	if not LoadingScreen.background.visible:
		LoadingScreen.animations.play("Fade_In")
		yield(LoadingScreen.animations, "animation_finished")
	generation_thread.start(self, "_generate_level")

# Generates a new level
# Carried out on the generation thread
func _generate_level():
	# Randomise the rng / seed
	GameManager.rng.randomize()
	GameManager.rng.set_seed(5889686823930929366)
	print("The cave seed is: " + str(GameManager.rng.get_seed()))
	
	# Remove tilemaps from the scene tree, as manipulating them
	# directly on the scene tree from inside a thread crashes the game
	var nodes = []
	for node in world.get_children():
		world.remove_child(node)
		nodes.append(node)
	
	walls.initialise_walls_layer()
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

	mining_grid.initialise_mining_grid()
	
	# Add the tilemaps back to the scene tree
	for node in nodes:
		world.add_child(node)
	
	call_deferred("post_generation")

# Called on the main thread,
# after the generation thread has finished generating a new level
func post_generation():
	generation_thread.wait_to_finish()
	LoadingScreen.animations.play("Fade_Out")
	yield(LoadingScreen.animations, "animation_finished")
	GameManager.increase_cave_depth()
	level_title.add_title_to_queue("Cave Depth\n" + str(GameManager.cave_depth))

func _process(delta):
	if objects.player_exists():
		var player_pos = objects.get_player().position
		minimap.update_player_pos(player_pos, ceiling)

func _unhandled_input(event):
	if event.is_action_pressed("force_exit_cave"):
		on_player_exited_cave()
	elif event.is_action_pressed("load_magpie_level"):
		if generation_thread.is_active() or LoadingScreen.animations.is_playing():
			return
		LoadingScreen.load_scene("res://World/MagpieLevel/MagpieLevel.tscn")

# Called when the player enters the CaveExit detection radius
func on_player_exited_cave():
	if LoadingScreen.background.visible or generation_thread.is_active():
		return
	if GameManager.magie_level_should_spawn():
		LoadingScreen.load_scene("res://World/MagpieLevel/MagpieLevel.tscn")
	else:
		generate_level()
