extends Area2D

# Constants
const BULLET_SPEED = 100

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
	queue_free()

# Called when an area enters the bullet's hurtbox
func on_area_entered_hurtbox(area):
	print("hit enemy!")
	var enemy = area.get_parent()
	# As the enemy is not a "body", invoke on_collision() manually
	on_collision(enemy)
