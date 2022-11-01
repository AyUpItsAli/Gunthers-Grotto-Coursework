extends Area2D

# Constants
const BULLET_SPEED = 300
const BULLET_DAMAGE = 3

# Variables
var player: Player # Player node that shot the bullet
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
	var node = area.get_parent()
	if node.has_method("take_damage"):
		node.take_damage(player, BULLET_DAMAGE)
	on_collision(node) # Bullet has collided with enemy
