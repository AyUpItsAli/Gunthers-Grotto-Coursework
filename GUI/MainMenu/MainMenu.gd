extends Control

# Node references
onready var version_label = $Version
onready var play_button = $PlayButton
onready var quit_button = $QuitButton

func _ready():
	play_button.connect("pressed", self, "on_play_button_pressed")
	quit_button.connect("pressed", self, "on_quit_button_pressed")
	Overlay.hide_hud()
	version_label.text = ProjectSettings.get_setting("application/config/name") + " " + Globals.PRODUCT_VERSION
	if Loading.is_loading_screen_showing():
		Loading.hide_loading_screen()

func on_quit_button_pressed():
	if Loading.is_loading_screen_showing(): return
	# Close the program
	get_tree().quit()

func on_play_button_pressed():
	if Loading.is_loading_screen_showing(): return
	# Reset game data, eg: score, health and inventory
	GameManager.reset_game_data()
	PlayerData.reset_player_data()
	# Load the main level scene
	Loading.change_scene("res://World/Level/Level.tscn")
