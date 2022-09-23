extends Node2D

onready var base_sprite = $BaseSprite
onready var fill_sprite = $FillSprite

const VIEWPORT_PERCENTAGE = 25
const PADDING = 10 # Space between the health bar and the edge of the screen

func _ready():
	get_viewport().connect("size_changed", self, "update_scale")
	PlayerData.connect("health_changed", self, "update_health_bar")
	update_scale()

# Scale's the width of the health bar so that it occupies a certain
# percentage of the screen
func update_scale():
	var viewport_width = get_viewport_rect().size.x
	var health_bar_width = base_sprite.texture.get_width()
	var multiplier = VIEWPORT_PERCENTAGE / 100.0
	scale.x = (viewport_width * multiplier) / health_bar_width
	scale.y = scale.x # Scale in the Y axis as well, to keep original shape
	
	# Place the health bar at the bottom of the screen
	var padding = (PADDING * scale.x) # Scale padding as well
	position.y = get_viewport_rect().size.y - padding # Subtracting = upwards
	position.x = padding

# Sets the Fill Sprite's scale to the ratio between the player's health
# and their maximum health
func update_health_bar():
	fill_sprite.scale.x = PlayerData.health / float(PlayerData.MAX_HEALTH)
