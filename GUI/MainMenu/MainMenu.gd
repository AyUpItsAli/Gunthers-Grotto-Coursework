extends Control

# Node references
onready var play_button = $PlayButton
onready var quit_button = $QuitButton
onready var loading_screen = $LoadingScreen

func _ready():
	play_button.connect("pressed", self, "on_play_button_pressed")
	quit_button.connect("pressed", self, "on_quit_button_pressed")

func on_quit_button_pressed():
	# Prevent the user from pressing the button again
	quit_button.disabled = true
	# Close the program
	get_tree().quit()

func on_play_button_pressed():
	# Prevent the user from pressing the button again
	play_button.disabled = true
	# Reset game data, eg: score, health and inventory
	GameManager.reset_score()
	PlayerData.reset_player_data()
	# Play loading screen animation
	var animations = loading_screen.get_node("LoadingScreenAnimations")
	animations.play("Fade_In")
	yield(animations, "animation_finished")
	# Load the main level scene
	get_tree().change_scene("res://World/Level/Level.tscn")
