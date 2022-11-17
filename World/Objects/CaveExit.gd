extends Node2D

func _ready():
	$DetectionRadius.connect("body_entered", self, "on_player_entered")

func on_player_entered(player: Player):
	player.exit_cave(position)
