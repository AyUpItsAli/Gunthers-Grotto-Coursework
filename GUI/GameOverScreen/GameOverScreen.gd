extends Control

onready var final_score_label = $FinalScore/Label
onready var menu_button = $MenuButton

func _ready():
	menu_button.connect("pressed", self, "on_menu_button_pressed")
	final_score_label.text = "Final Score: " + str(GameManager.cave_depth)
	if Loading.is_showing():
		Loading.hide()

func on_menu_button_pressed():
	if Loading.is_showing(): return
	# Load the main menu scene
	Loading.change_scene("res://GUI/MainMenu/MainMenu.tscn")
