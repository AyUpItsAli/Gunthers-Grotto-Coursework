extends KinematicBody2D

# Constants
const MOVE_SPEED = 100

var velocity = Vector2.ZERO

func determine_velocity(delta):
	velocity = Vector2.ZERO # Reset velocity to 0
	
	# Alter velocity vector based on user inputs
	if Input.is_action_pressed("move_left"): velocity.x -= 1
	if Input.is_action_pressed("move_right"): velocity.x += 1
	if Input.is_action_pressed("move_up"): velocity.y -= 1
	if Input.is_action_pressed("move_down"): velocity.y += 1
	
	# Normalize the vector then multiply by movement speed and delta time
	velocity = velocity.normalized() * MOVE_SPEED * delta

func _process(delta):
	determine_velocity(delta)
	# Move the player via their velocity vector
	velocity = move_and_slide(velocity)
