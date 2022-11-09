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
	generate_new_level()

func generate_new_level():
	if generation_thread.is_active(): return
	if not LoadingScreen.is_showing():
		yield(LoadingScreen.show(), "completed")
	
	# Randomise the rng / seed
	GameManager.rng.randomize()
	print("The cave seed is: " + str(GameManager.rng.get_seed()))
	
	generation_thread.start(self, "_generate_new_level")

func _generate_new_level():
	# Remove child nodes from the scene tree, before manipulating them
	var children = []
	for child in get_children():
		remove_child(child)
		children.append(child)
	
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
	
	# Add the child nodes back to the scene tree, after manipulating them
	for child in children:
		add_child(child)
	
	call_deferred("post_generation")

func post_generation():
	generation_thread.wait_to_finish()
	if LoadingScreen.is_showing():
		yield(LoadingScreen.hide(), "completed")
	GameManager.increase_cave_depth()
	level_title.add_title_to_queue("Cave Depth\n" + str(GameManager.cave_depth))

func _process(delta):
	if objects.player_exists():
		var player_pos = objects.get_player().position
		minimap.update_player_pos(player_pos, ceiling)

# Called when the player enters the CaveExit detection radius
func on_player_exited_cave():
	if LoadingScreen.is_showing(): return
	
	if GameManager.magie_level_should_spawn():
		LoadingScreen.change_scene("res://World/MagpieLevel/MagpieLevel.tscn")
	else:
		generate_new_level()

# DEBUG keybinds to instantly load next level or magpie level
func _unhandled_input(event):
	if event.is_action_pressed("force_exit_cave"):
		on_player_exited_cave()
	elif event.is_action_pressed("load_magpie_level"):
		if LoadingScreen.is_showing(): return
		LoadingScreen.change_scene("res://World/MagpieLevel/MagpieLevel.tscn")
