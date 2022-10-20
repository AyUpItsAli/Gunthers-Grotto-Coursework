extends Node2D

# Node references
onready var rock_layer = $RockLayer
onready var player = $Objects/Player
onready var cave_exit = $Objects/CaveExit

# HUD
onready var minimap = $HUD/UI/Minimap
onready var loading_screen = $HUD/LoadingScreen

func _ready():
	cave_exit.connect("player_entered", self, "on_player_exited_cave")
	
	# Reset the number of caves since the magpie level spawned
	GameManager.caves_since_magpie = 0
	
	# Update the minimap to display the layout of the magpie level
	minimap.update_minimap(rock_layer)
	
	# Setup the limits for the player's camera
	var rect = rock_layer.get_used_rect()
	var camera: Camera2D = player.get_camera()
	camera.limit_left = (rect.position.x + 1) * Globals.CAVE_TILE_SIZE
	camera.limit_top = (rect.position.y + 1) * Globals.CAVE_TILE_SIZE
	camera.limit_right = (rect.position.x + rect.size.x - 1) * Globals.CAVE_TILE_SIZE
	camera.limit_bottom = (rect.position.y + rect.size.y - 1) * Globals.CAVE_TILE_SIZE
	
	# Fade out the loading screen
	if loading_screen.visible:
		var animations = loading_screen.get_node("LoadingScreenAnimations")
		animations.play("Fade_Out")

func _process(delta):
	var player_tile_pos = rock_layer.world_to_map(player.position)
	minimap.update_player_pos(player_tile_pos)

# Called when the player enters the CaveExit detection radius
func on_player_exited_cave():
	if not loading_screen.visible:
		var animations = loading_screen.get_node("LoadingScreenAnimations")
		animations.play("Fade_In")
		yield(animations, "animation_finished")
		get_tree().change_scene("res://World/Level/Level.tscn")
