extends KinematicBody2D

# Constants
const MOVE_SPEED = 5000
enum Tools { PICKAXE, REVOLVER, DYNAMITE }
const PICKAXE_TEXTURE = preload("res://Assets/Actors/Player/Pickaxe.png")
const REVOLVER_TEXTURE = preload("res://Assets/Actors/Player/Revolver.png")
const DYNAMITE_TEXTURE = preload("res://Assets/Actors/Player/Dynamite.png")
const PICKAXE_DAMAGE = 1
const BULLET = preload("res://Actors/Player/Bullet.tscn")

# Node references
onready var body_sprite: Sprite = $BodySprite
onready var item_sprite: Sprite = $ItemSprite
onready var player_animations: AnimationPlayer = $PlayerAnimations
onready var attacking_hurtbox: Area2D = $AttackingHurtbox
onready var mining_hurtbox: Area2D = $MiningHurtbox

var velocity = Vector2.ZERO
var facing = Vector2.DOWN
var equipped = Tools.PICKAXE
var attacking = false

func get_camera():
	return get_node("Camera")

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
	var facing_before = facing
	determine_facing()
	
	# Render body sprite above item sprite if facing upwards
	if facing != facing_before:
		if facing == Vector2.UP:
			move_child(body_sprite, 1)
		else:
			move_child(body_sprite, 0)
	
	# Avoid overriding any "attack" animations for each of the tools
	if not attacking:
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
	
	# Rotate hurtboxes to face the mouse
	var mouse_pos = get_global_mouse_position()
	attacking_hurtbox.look_at(mouse_pos)
	mining_hurtbox.look_at(mouse_pos)

# Sets the texture of the itsprite to display the correct tool
func update_item_sprite():
	match equipped:
		Tools.PICKAXE: item_sprite.texture = PICKAXE_TEXTURE
		Tools.REVOLVER: item_sprite.texture = REVOLVER_TEXTURE
		Tools.DYNAMITE: item_sprite.texture = DYNAMITE_TEXTURE
		_: item_sprite.texture = null

# Equips a new tool and then updates the item sprite
func equip(new_tool: int):
	equipped = new_tool
	update_item_sprite()

# Calls the "on_player_mine" method
# on all bodies overlapping the mining hurtbox
func mine_objects():
	for body in mining_hurtbox.get_overlapping_bodies():
		if body.has_method("on_player_mine"):
			var pos = mining_hurtbox.get_node("CollisionShape").global_position
			body.on_player_mine(pos)

# Calls the "take_damage" method
# on enemy hitboxes overlapping the mining hurtbox
func damage_enemies():
	for area in attacking_hurtbox.get_overlapping_areas():
		var node = area.get_parent()
		if node.has_method("take_damage"):
			node.take_damage(PICKAXE_DAMAGE)

# Called when the user presses left-click.
# Carrys out the action specific to the currently equipped tool.
func use_tool():
	if equipped == Tools.PICKAXE:
		attacking = true
		
		match facing:
			Vector2.UP: player_animations.play("Melee_Up")
			Vector2.RIGHT: player_animations.play("Melee_Right")
			Vector2.LEFT: player_animations.play("Melee_Left")
			_: player_animations.play("Melee_Down")
		
		mine_objects()
		damage_enemies()
		
		yield(player_animations, "animation_finished")
		attacking = false
	elif equipped == Tools.REVOLVER:
		var bullet = BULLET.instance()
		bullet.position = position
		bullet.velocity = Vector2.RIGHT
		get_parent().add_child(bullet)

# Called when this node detects mouse/keyboard inputs
func _unhandled_input(event):
	if event.is_action_pressed("equip_pickaxe"):
		equip(Tools.PICKAXE)
	elif event.is_action_pressed("equip_revolver"):
		equip(Tools.REVOLVER)
	elif event.is_action_pressed("equip_dynamite"):
		equip(Tools.DYNAMITE)
	elif event.is_action_pressed("use_tool"):
		use_tool()

func take_damage(damage: int):
	body_sprite.modulate = Color.red
	PlayerData.reduce_health(damage)
	yield(get_tree().create_timer(0.1), "timeout")
	body_sprite.modulate = Color.white
