class_name Player
extends KinematicBody2D

# Constants
const MOVE_SPEED = 5000
const PICKAXE_TEXTURE = preload("res://Assets/Actors/Player/Pickaxe_In_Hand.png")
const REVOLVER_TEXTURE = preload("res://Assets/Actors/Player/Revolver_In_Hand.png")
const DYNAMITE_TEXTURE = preload("res://Assets/Actors/Player/Dynamite_In_Hand.png")
const PLAYER_SCENT = preload("res://Actors/Player/PlayerScent.tscn")
enum Tools { PICKAXE, REVOLVER, DYNAMITE }

# Node references
onready var body_sprite: Sprite = $BodySprite
onready var item_sprite: Sprite = $ItemSprite
onready var animations: AnimationPlayer = $Animations
onready var hitbox: Area2D = $Hitbox
onready var attacking_hurtbox: Area2D = $AttackingHurtbox
onready var mining_hurtbox: Area2D = $MiningHurtbox
onready var pickaxe_cooldown: Timer = $PickaxeCooldown
onready var revolver_cooldown: Timer = $RevolverCooldown
onready var dynamite_cooldown: Timer = $DynamiteCooldown
onready var main_state_machine: StateMachine = $MainStateMachine
onready var action_state_machine: StateMachine = $ActionStateMachine

var velocity = Vector2.ZERO
var facing = Vector2.DOWN
var equipped = Tools.PICKAXE
var scent_trail = []

func _ready():
	$ScentTimer.connect("timeout", self, "leave_scent")

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

# Returns the intended velocity of the player based on user inputs
func get_intended_velocity(delta) -> Vector2:
	var intended_velocity = Vector2.ZERO
	if Input.is_action_pressed("move_left"): intended_velocity.x -= 1
	if Input.is_action_pressed("move_right"): intended_velocity.x += 1
	if Input.is_action_pressed("move_up"): intended_velocity.y -= 1
	if Input.is_action_pressed("move_down"): intended_velocity.y += 1
	
	return intended_velocity.normalized() * MOVE_SPEED * delta

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
# Reduces the player's health and triggers death state
func take_damage(damage: int):
	if main_state_machine.is_state("Dead"): return
	body_sprite.modulate = Color.red
	var survived = PlayerData.reduce_health(damage)
	yield(get_tree().create_timer(0.1), "timeout")
	body_sprite.modulate = Color.white
	if not survived: main_state_machine.enter_state("Dead")

# Spawns player scent at the player's current position
func leave_scent():
	if main_state_machine.is_state("Dead"): return
	var scent = PLAYER_SCENT.instance()
	scent.player = self
	scent.position = position
	get_parent().add_child(scent)
	scent_trail.push_front(scent)

# Clears the player's scent trail
func clear_scent_trail():
	for scent in scent_trail:
		scent.queue_free()
	scent_trail.clear()

func get_camera():
	return get_node("Camera")
