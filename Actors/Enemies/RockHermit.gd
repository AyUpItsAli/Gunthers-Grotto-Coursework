extends KinematicBody2D

# Node references
onready var search_radius: Area2D = $SearchRadius
onready var world: Navigation2D = get_parent().get_parent()
onready var navigation_line: Line2D = $NavigationLine

# Variables
var player: KinematicBody2D # Reference to the player node, once detected
var path: Array # Array of points that the enemy must follow

func _ready():
	search_radius.connect("body_entered", self, "body_entered_search_radius")

func body_entered_search_radius(body):
	if not player:
		if body.name == "Player":
			player = body

# Stores an array of points leading towards the player in the path variable
func determine_path_to_player():
	if player:
		path = world.get_simple_path(position, player.position, false)
		navigation_line.points = path

func _process(delta):
	navigation_line.global_position = Vector2.ZERO
	if player:
		determine_path_to_player()
