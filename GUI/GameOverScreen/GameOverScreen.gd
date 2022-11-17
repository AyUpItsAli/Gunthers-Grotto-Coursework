extends Control

onready var final_score_label = $FinalScore/Label
onready var menu_button = $MenuButton

func _ready():
	menu_button.connect("pressed", self, "on_menu_button_pressed")
	final_score_label.text = "Final Score: " + str(GameManager.cave_depth)
	if LoadingScreen.is_showing():
		LoadingScreen.hide()

func on_menu_button_pressed():
	if LoadingScreen.is_showing(): return
	# Load the main menu scene
	LoadingScreen.change_scene("res://GUI/MainMenu/MainMenu.tscn")
