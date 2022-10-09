extends Area2D

const MOVE_SPEED = 10

onready var hurtbox: Area2D = $Hurtbox

var velocity: Vector2

func _ready():
	connect("body_entered", self, "on_collision")
	connect("area_entered", self, "on_collision")
	hurtbox.connect("area_entered", self, "on_area_entered_hurtbox")

func _physics_process(delta):
	position += velocity * MOVE_SPEED * delta

# Called when the bullet collides with anything (bodies and areas included)
func on_collision(body_or_area):
	queue_free()

# Called when an area enters the bullet's hurtbox
func on_area_entered_hurtbox(area):
	print("hurt enemy")
