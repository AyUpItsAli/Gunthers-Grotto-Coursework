extends Node2D

# Node references
onready var walls = $Walls
onready var player = $Objects/Player
onready var cave_exit = $Objects/CaveExit
onready var ceiling = $Ceiling

# HUD
onready var minimap = $HUD/UI/Minimap
onready var level_title = $HUD/UI/LevelTitle

func _ready():
	cave_exit.connect("player_entered", self, "on_player_exited_cave")
	
	# Reset the number of caves since the magpie level spawned
	GameManager.caves_since_magpie = 0
	
	# Update the minimap to display the layout of the magpie level
	minimap.update_minimap(walls)
	
	# Setup the limits for the player's camera
	var rect = walls.get_used_rect()
	var camera: Camera2D = player.get_camera()
	camera.limit_left = (rect.position.x + 1) * Globals.CAVE_TILE_SIZE
	camera.limit_top = (rect.position.y + 1) * Globals.CAVE_TILE_SIZE
	camera.limit_right = (rect.position.x + rect.size.x - 1) * Globals.CAVE_TILE_SIZE
	camera.limit_bottom = (rect.position.y + rect.size.y - 1) * Globals.CAVE_TILE_SIZE
	
	if LoadingScreen.is_showing():
		yield(LoadingScreen.hide(), "completed")
	level_title.add_title_to_queue("The Magpie")

func _process(delta):
	minimap.update_player_pos(player.position, ceiling)

# Called when the player enters the CaveExit detection radius
func on_player_exited_cave():
	LoadingScreen.change_scene("res://World/Level/Level.tscn")
