extends Area2D

# Constants
const DYNAMITE_SPEED = 200
const EXPLOSION_DAMAGE = 5

# Node references
onready var sprite: Sprite = $Sprite
onready var explosion_timer: Timer = $ExplosionTimer
onready var explosion_radius: Area2D = $ExplosionRadius
onready var explosion: Particles2D = $Explosion

# Variables
var destination: Vector2
var destination_reached = false
var previous_velocity: Vector2
var exploded = false

func _ready():
	connect("body_entered", self, "on_collision")
	explosion_timer.connect("timeout", self, "explode")
	explosion_timer.start()

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

# Called when the dynamite collides with something "physical"
func on_collision(body):
	if destination_reached: return
	if body.name == "WallsLayer": return # Pass freely over wall tiles
	explode()

# Called when the explosion timer times out, OR
# when the dynamite collides with something
func explode():
	if exploded: return # Don't explode if already exploded
	
	reach_destination() # Dynamite should stop moving
	exploded = true # Dynamite has now exploded
	
	# Damage the owners of overlapping hitboxes, including the player
	for area in explosion_radius.get_overlapping_areas():
		var node = area.get_parent()
		if node.has_method("take_damage"):
			node.take_damage(EXPLOSION_DAMAGE)
	# Let objects know that an explosion took place at the given position
	for body in explosion_radius.get_overlapping_bodies():
		if body.has_method("on_explosion"):
			body.on_explosion(position)
	
	# Hide the dynamite sprite and set the explosion effect to start emitting
	sprite.visible = false
	explosion.emitting = true
	
	# Wait out the duration of the explosion effect, then remove the dynamite
	yield(get_tree().create_timer(explosion.lifetime), "timeout")
	queue_free()
