extends Node2D

# Node references
onready var ground = $Ground
onready var walls = $Walls
onready var objects = $Objects
onready var ceiling = $Ceiling
onready var mining_grid = $MiningGrid

# HUD
onready var map = Overlay.get_node("HUD/Map")
onready var level_title = Overlay.get_node("HUD/LevelTitle")

var generation_thread := Thread.new()

func _ready():
	Overlay.show_hud()
	generate_new_level()

func generate_new_level():
	if generation_thread.is_active(): return
	if not Loading.is_loading_screen_showing():
		yield(Loading.show_loading_screen(), "completed")
	
	# Randomise the rng / seed
	GameManager.rng.randomize()
	print("The cave seed is: " + str(GameManager.rng.get_seed()))
	
	generation_thread.start(self, "_generate_new_level")

# Called on the generation thread
func _generate_new_level():
	# Remove child nodes from the scene, before manipulating them
	# This is because Godot crashes if you set tilemap cells directly
	# on the scene tree, when not in the main thread
	var children = []
	for child in get_children():
		remove_child(child)
		children.append(child)
	# Do the same thing with the Map node which is part of the Overlay scene (not this scene)
	# Also store the map's parent, and position within its parent, for later
	var map_parent = map.get_parent()
	var map_parent_pos = map.get_position_in_parent()
	map_parent.remove_child(map)
	
	# Generate the main cave shape
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
	
	# Update the map to display the layout of the new level, then hide it
	map.update_map(walls)
	map.visible = false
	
	# Spawn objects
	objects.clear_objects()
	objects.spawn_stalagmites()
	objects.spawn_gemstones()
	objects.spawn_player()
	objects.spawn_cave_exit()
	
	# Initialise the mining grid,
	# so it can connect to the player's "pickaxe_used" signal
	mining_grid.initialise_mining_grid()
	
	# Add the child nodes back to the scene tree, after manipulating them
	for child in children:
		add_child(child)
	# Add the Map node back to the Overlay scene, in the correct position
	map_parent.add_child(map)
	map_parent.move_child(map, map_parent_pos)
	
	call_deferred("post_generation")

func post_generation():
	generation_thread.wait_to_finish()
	if Loading.is_loading_screen_showing():
		yield(Loading.hide_loading_screen(), "completed")
	GameManager.increase_cave_depth()
	level_title.add_title_to_queue("Cave Depth\n" + str(GameManager.cave_depth))

func _process(delta):
	if objects.player_exists():
		var player = objects.get_player()
		var canvas_transform = player.get_global_transform_with_canvas()
		map.update_position(canvas_transform.get_origin(), player.position)

# Called when the player enters the CaveExit detection radius
func on_player_exited_cave():
	if Loading.is_loading_screen_showing(): return
	
	if GameManager.magie_level_should_spawn():
		Loading.change_scene("res://World/MagpieLevel/MagpieLevel.tscn")
	else:
		generate_new_level()

# DEBUG keybinds to instantly load next level or magpie level
func _unhandled_input(event):
	if event.is_action_pressed("force_exit_cave"):
		on_player_exited_cave()
	elif event.is_action_pressed("load_magpie_level"):
		if Loading.is_loading_screen_showing(): return
		Loading.change_scene("res://World/MagpieLevel/MagpieLevel.tscn")
