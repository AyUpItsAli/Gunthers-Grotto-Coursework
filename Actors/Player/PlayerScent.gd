extends Node2D

var player

func _ready():
	$ExpirationTimer.connect("timeout", self, "remove_scent")

# Removes the scent once it has expired
func remove_scent():
	player.scent_trail.erase(self)
	queue_free()
