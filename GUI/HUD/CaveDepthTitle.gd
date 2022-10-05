extends Node2D

onready var label: Label = $Label
onready var animations: AnimationPlayer = $LabelAnimations

var queue = [] # List of cave depths, in order, to be displayed to the user

func _process(delta):
	if queue and not animations.is_playing():
		label.text = "Cave Depth\n" + str(queue[0])
		animations.play("Show")
		queue.pop_front()

func add_depth_to_queue(depth: int):
	if not depth in queue:
		queue.append(depth)
