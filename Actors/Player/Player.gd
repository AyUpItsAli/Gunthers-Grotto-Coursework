extends KinematicBody2D

# Constants
const MOVE_SPEED = 5000

# Node references
onready var body_sprite: Sprite = $BodySprite
onready var player_animations: AnimationPlayer = $PlayerAnimations

var velocity = Vector2.ZERO
var facing = Vector2.DOWN

func determine_velocity(delta):
	velocity = Vector2.ZERO # Reset velocity to 0
	
	# Alter velocity vector based on user inputs
	if Input.is_action_pressed("move_left"): velocity.x -= 1
	if Input.is_action_pressed("move_right"): velocity.x += 1
	if Input.is_action_pressed("move_up"): velocity.y -= 1
	if Input.is_action_pressed("move_down"): velocity.y += 1
	
	# Normalize the vector then multiply by movement speed and delta time
	velocity = velocity.normalized() * MOVE_SPEED * delta

func _physics_process(delta):
	determine_velocity(delta)
	# Move the player via their velocity vector
	velocity = move_and_slide(velocity)

func determine_facing():
	var mouse_pos = get_local_mouse_position()
	
	if -abs(mouse_pos.y) > mouse_pos.x:
		facing = Vector2.LEFT
	elif abs(mouse_pos.y) < mouse_pos.x:
		facing = Vector2.RIGHT
	elif -abs(mouse_pos.x) > mouse_pos.y:
		facing = Vector2.UP
	else:
		facing = Vector2.DOWN

func _process(delta):
	determine_facing()
	
	if velocity != Vector2.ZERO: # Is the player moving?
		match facing:
			Vector2.UP: player_animations.play("Walk_Up")
			Vector2.RIGHT: player_animations.play("Walk_Right")
			Vector2.LEFT: player_animations.play("Walk_Left")
			_: player_animations.play("Walk_Down")
	else:
		match facing:
			Vector2.UP: player_animations.play("Idle_Up")
			Vector2.RIGHT: player_animations.play("Idle_Right")
			Vector2.LEFT: player_animations.play("Idle_Left")
			_: player_animations.play("Idle_Down")
