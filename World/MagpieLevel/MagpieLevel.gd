extends Node2D

# Node references
onready var rock_layer = $RockLayer
onready var player = $Objects/Player

# HUD
onready var minimap = $HUD/UI/Minimap
onready var loading_screen = $HUD/LoadingScreen

func _ready():
	# Update the minimap to display the layout of the magpie level
	minimap.update_minimap(rock_layer)
	
	# Fade out the loading screen
	if loading_screen.visible:
		var animations = loading_screen.get_node("LoadingScreenAnimations")
		animations.play("Fade_Out")

func _process(delta):
	var player_tile_pos = rock_layer.world_to_map(player.position)
	minimap.update_player_pos(player_tile_pos)
