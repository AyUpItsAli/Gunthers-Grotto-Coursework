extends Node2D

# Node references
onready var ground_layer = $GroundLayer
onready var rock_layer = $RockLayer
onready var objects = $Objects

# HUD
onready var minimap = $HUD/UI/Minimap
onready var loading_screen = $HUD/LoadingScreen

func _ready():
	load_level() # Do any required setup for the magpie level

func _process(delta):
	if objects.player_exists():
		var player_pos = objects.get_player().position
		var player_tile_pos = ground_layer.world_to_map(player_pos)
		minimap.update_player_pos(player_tile_pos)

# Loads the magpie level
func load_level():
	# Update the minimap to match the rock layer
	minimap.update_minimap(rock_layer)
	
	# Fade out the loading screen
	if loading_screen.visible:
		var animations = loading_screen.get_node("LoadingScreenAnimations")
		animations.play("Fade_Out")
