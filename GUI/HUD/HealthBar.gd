extends Node2D

onready var fill_sprite = $FillSprite

func _ready():
	PlayerData.connect("health_changed", self, "update_health_bar")

# Sets the Fill Sprite's scale to the ratio between the player's health
# and their maximum health
func update_health_bar():
	fill_sprite.scale.x = PlayerData.health / float(PlayerData.MAX_HEALTH)
