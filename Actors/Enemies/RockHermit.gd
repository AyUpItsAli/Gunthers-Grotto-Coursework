extends KinematicBody2D

# Constants
const TEXTURE_LEFT = preload("res://Assets/Actors/Enemies/Rock_Hermit_Left.png")
const TEXTURE_RIGHT = preload("res://Assets/Actors/Enemies/Rock_Hermit_Right.png")
const MOVE_SPEED = 2500
const STOP_DISTANCE = 25
const ATTACK_DAMAGE = 1

# Node references
onready var search_radius: Area2D = $SearchRadius
onready var sprite: Sprite = $Sprite
onready var hurtbox: Area2D = $Hurtbox
onready var attack_timer: Timer = $AttackTimer

# Variables
var player: KinematicBody2D # Reference to the player node, once detected
var velocity = Vector2.ZERO
var health = 5

func _ready():
	search_radius.connect("body_entered", self, "body_entered_search_radius")
	hurtbox.connect("area_entered", self, "area_entered_hurtbox")
	attack_timer.connect("timeout", self, "attack")

func body_entered_search_radius(body):
	if not player and body.name == "Player":
		player = body

func determine_sprite():
	if player:
		if player.position.x > position.x:
			sprite.texture = TEXTURE_RIGHT
		elif player.position.x < position.x:
			sprite.texture = TEXTURE_LEFT

func _physics_process(delta):
	if player:
		determine_sprite()
		hurtbox.look_at(player.position)
	velocity = move_and_slide(velocity)

func take_damage(damage: int):
	sprite.modulate = Color.red
	health -= damage
	if health <= 0:
		return queue_free()
	yield(get_tree().create_timer(0.1), "timeout")
	sprite.modulate = Color.white

func area_entered_hurtbox(area):
	attack_timer.start()

func attack():
	var areas = hurtbox.get_overlapping_areas()
	if areas.size() > 0:
		var hitbox: Area2D = areas[0]
		var player = hitbox.get_parent()
		if player.has_method("take_damage"):
			player.take_damage(ATTACK_DAMAGE)
		attack_timer.start()

# --- OLD PATHFINDING CODE ---
## Stores an array of points leading towards the player in the path variable
#func determine_path_to_player():
#	if player:
#		path = world.get_simple_path(position, player.position, false)
#		navigation_line.points = path
#
## Determines the enemy's velocity to move along the path
#func determine_velocity(delta):
#	velocity = Vector2.ZERO
#	if player and path.size() > 0:
#		if position.distance_to(player.position) > STOP_DISTANCE:
#			# If reached first point
#			# Remove point from list
#			if position == path[0]:
#				path.pop_front()
#			# Set velocity towards the next point
#			velocity = position.direction_to(path[0]) * MOVE_SPEED * delta
