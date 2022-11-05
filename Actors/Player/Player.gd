class_name Player
extends KinematicBody2D

# Constants
enum Tools { PICKAXE, REVOLVER, DYNAMITE }
const PICKAXE_TEXTURE = preload("res://Assets/Actors/Player/Pickaxe_In_Hand.png")
const REVOLVER_TEXTURE = preload("res://Assets/Actors/Player/Revolver_In_Hand.png")
const DYNAMITE_TEXTURE = preload("res://Assets/Actors/Player/Dynamite_In_Hand.png")

# Node references
onready var body_sprite: Sprite = $BodySprite
onready var item_sprite: Sprite = $ItemSprite
onready var animations: AnimationPlayer = $Animations
onready var hitbox: Area2D = $Hitbox
onready var hurtbox: Area2D = $Hurtbox
onready var pickaxe_cooldown: Timer = $PickaxeCooldown
onready var revolver_cooldown: Timer = $RevolverCooldown
onready var dynamite_cooldown: Timer = $DynamiteCooldown
onready var main_state_machine: StateMachine = $MainStateMachine
onready var action_state_machine: StateMachine = $ActionStateMachine

var velocity = Vector2.ZERO
var facing = Vector2.DOWN
var equipped = Tools.PICKAXE
var scent_trail = []

signal pickaxe_used # Emitted when the player uses their pickaxe

func _ready():
	$ScentTimer.connect("timeout", self, "leave_scent")

func get_camera():
	return get_node("Camera")

# Determines the player's facing direction based on the mouse position
func determine_facing():
	var facing_before = facing
	
	var mouse_pos = get_local_mouse_position()
	if -abs(mouse_pos.y) > mouse_pos.x: facing = Vector2.LEFT
	elif abs(mouse_pos.y) < mouse_pos.x: facing = Vector2.RIGHT
	elif -abs(mouse_pos.x) > mouse_pos.y: facing = Vector2.UP
	else: facing = Vector2.DOWN
	
	# Render body sprite above item sprite if facing upwards
	if facing != facing_before:
		if facing == Vector2.UP: move_child(body_sprite, 1)
		else: move_child(body_sprite, 0)

# Rotate the hurtboxes to face the mouse
func rotate_hurtboxes():
	var mouse_pos = get_global_mouse_position()
	attacking_hurtbox.look_at(mouse_pos)
	mining_hurtbox.look_at(mouse_pos)

# Equips the given tool and updates the item sprite
func equip(new_tool: int):
	equipped = new_tool
	update_item_sprite()

# Sets the texture of the item sprite to display the currently equipped tool
func update_item_sprite():
	match equipped:
		Tools.PICKAXE: item_sprite.texture = PICKAXE_TEXTURE
		Tools.REVOLVER: item_sprite.texture = REVOLVER_TEXTURE
		Tools.DYNAMITE: item_sprite.texture = DYNAMITE_TEXTURE
		_: item_sprite.texture = null

# Called, usually externally, when the player needs to take damage
func take_damage(attacker, damage: int):
	main_state_machine.call_method("take_damage", [attacker, damage])

# Called when scent timer times out
func leave_scent():
	main_state_machine.call_method("leave_scent")
