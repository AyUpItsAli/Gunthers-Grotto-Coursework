extends Node2D

signal player_entered

func _ready():
	$DetectionRadius.connect("body_entered", self, "on_player_entered")

func on_player_entered(player):
	print("Player entered Cave Exit...")
	emit_signal("player_entered") # Caught by the root node of the Level
