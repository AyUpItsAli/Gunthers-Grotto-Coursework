extends Area2D

# Constants
const BULLET_SPEED = 200
const BULLET_DAMAGE = 1

# Variables
var velocity: Vector2

func _ready():
	connect("body_entered", self, "on_collision")
	$Hurtbox.connect("area_entered", self, "on_area_entered_hurtbox")

func _physics_process(delta):
	position += velocity * BULLET_SPEED * delta

# Called when the bullet collides with something "physical"
# The bullet should be destroyed on impact
func on_collision(body):
	if body.name == "WallsLayer": return # Pass freely over wall tiles
	queue_free()

# Called when an area enters the bullet's hurtbox
func on_area_entered_hurtbox(area):
	var node = area.get_parent()
	if node.has_method("take_damage"):
		node.take_damage(BULLET_DAMAGE)
