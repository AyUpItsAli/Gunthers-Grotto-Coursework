extends Control

onready var final_score_label = $FinalScore/Label
onready var menu_button = $MenuButton

func _ready():
	menu_button.connect("pressed", self, "on_menu_button_pressed")
	Overlay.hide_hud()
	final_score_label.text = "Final Score: " + str(GameManager.cave_depth)
	if Loading.is_loading_screen_showing():
		Loading.hide_loading_screen()

func on_menu_button_pressed():
	if Loading.is_loading_screen_showing(): return
	# Load the main menu scene
	Loading.change_scene("res://GUI/MainMenu/MainMenu.tscn")
