class_name RockHermit
extends KinematicBody2D

# Constants
const ATTACK_DAMAGE = 1

# Node references
onready var body_sprite: Sprite = $BodySprite
onready var hurtbox: Area2D = $Hurtbox
onready var attack_timer: Timer = $AttackTimer
onready var detection_radius: Area2D = $DetectionRadius
onready var line_of_sight: RayCast2D = $LineOfSight
onready var state_machine: StateMachine = $StateMachine

# Variables
var target: Player
var direction: Vector2
var velocity = Vector2.ZERO
var health = 5

func _ready():
	detection_radius.connect("body_entered", self, "on_body_detected")
	$ChaseTimer.connect("timeout", self, "chase_target")

# Called when a body enters the enemy's detection radius
func on_body_detected(body):
	state_machine.call_method("on_body_detected", [body])

func chase_target():
	state_machine.call_method("chase_target")

# Called, usually externally, when the enemy needs to take damage
func take_damage(attacker, damage: int):
	state_machine.call_method("take_damage", [attacker, damage])

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
