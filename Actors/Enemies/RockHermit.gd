class_name RockHermit
extends KinematicBody2D

# Constants
const ATTACK_DAMAGE = 1

# Node references
onready var body_sprite: Sprite = $BodySprite
onready var soft_collision: Area2D = $SoftCollision
onready var detection_radius: Area2D = $DetectionRadius
onready var hurtbox: Area2D = $Hurtbox
onready var attack_delay_timer: Timer = $AttackDelayTimer # Delay before first attack
onready var attack_cooldown_timer: Timer = $AttackCooldownTimer # Cooldown between consecutive attacks
onready var target_ray: RayCast2D = $TargetRay
onready var debug_ray: RayCast2D = $DebugRay # Used to display vectors for debugging
onready var state_machine: StateMachine = $StateMachine

# Variables
var target: Player
var last_known_location: Vector2
var velocity = Vector2.ZERO
var health = 5

func _ready():
	hurtbox.connect("area_entered", self, "on_area_entered_hurtbox")
	attack_delay_timer.connect("timeout", self, "attack")
	attack_cooldown_timer.connect("timeout", self, "attack")

# Called, usually externally, when the enemy needs to take damage
func take_damage(attacker, damage: int):
	state_machine.call_method("take_damage", [attacker, damage])

# Called when the player's hitbox enters the enemy's hurtbox
func on_area_entered_hurtbox(area):
	attack_delay_timer.start()

# Called when the attack timer finishes
func attack():
	state_machine.call_method("attack")

# --- OLD ATTACKING CODE ---
#func area_entered_hurtbox(area):
#	attack_timer.start()
#
#func attack():
#	var areas = hurtbox.get_overlapping_areas()
#	if areas.size() > 0:
#		var hitbox: Area2D = areas[0]
#		var player = hitbox.get_parent()
#		if player.has_method("take_damage"):
#			player.take_damage(self, ATTACK_DAMAGE)
#		attack_timer.start()

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
