extends Area2D

# Constants
const DYNAMITE_SPEED = 200

# Node references
onready var sprite: Sprite = $Sprite
onready var explosion_timer: Timer = $ExplosionTimer
onready var explosion_radius: Area2D = $ExplosionRadius

# Variables
var destination: Vector2
var destination_reached = false
var previous_velocity: Vector2

# Called once the dynamite has reached its destination.
# Causes the dynamite to stop moving sets its Z index to -1
func reach_destination():
	destination_reached = true
	z_index = -1

func _physics_process(delta):
	if destination_reached: return
	
	var this_velocity = position.direction_to(destination)
	var same_sign_x = previous_velocity.x * this_velocity.x >= 0
	var same_sign_y = previous_velocity.y * this_velocity.y >= 0
	# Same signs = same direction
	if same_sign_x and same_sign_y:
		position += this_velocity * DYNAMITE_SPEED * delta
		previous_velocity = this_velocity
	else:
		reach_destination()
