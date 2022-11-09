extends Control

# Node references
onready var version_label = $Version
onready var play_button = $PlayButton
onready var quit_button = $QuitButton

func _ready():
	version_label.text = ProjectSettings.get_setting("application/config/name") + " " + Globals.PRODUCT_VERSION
	play_button.connect("pressed", self, "on_play_button_pressed")
	quit_button.connect("pressed", self, "on_quit_button_pressed")
	LoadingScreen.hide()

func on_quit_button_pressed():
	# Prevent the user from pressing the button again
	quit_button.disabled = true
	# Close the program
	get_tree().quit()

func on_play_button_pressed():
	# Prevent the user from pressing the button again
	play_button.disabled = true
	# Reset game data, eg: score, health and inventory
	GameManager.reset_game_data()
	PlayerData.reset_player_data()
	# Load the main level scene
	LoadingScreen.change_scene("res://World/Level/Level.tscn")
