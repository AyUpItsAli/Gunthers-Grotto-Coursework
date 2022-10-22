extends Control

onready var final_score_label = $FinalScore/Label
onready var menu_button = $MenuButton

func _ready():
	menu_button.connect("pressed", self, "on_menu_button_pressed")
	final_score_label.text = "Final Score: " + str(GameManager.cave_depth)

func on_menu_button_pressed():
	# Prevent the user from pressing the button again
	menu_button.disabled = true
	# Load the main menu scene
	get_tree().change_scene("res://GUI/MainMenu/MainMenu.tscn")
