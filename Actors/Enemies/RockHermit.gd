extends KinematicBody2D

# Node references
onready var search_radius: Area2D = $SearchRadius

# Variables
var player: KinematicBody2D # Reference to the player node, once detected

func _ready():
	search_radius.connect("body_entered", self, "body_entered_search_radius")

func body_entered_search_radius(body):
	if not player:
		if body.name == "Player":
			player = body

