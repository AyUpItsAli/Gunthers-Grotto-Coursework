extends Node2D

onready var label: Label = $Label
onready var animations: AnimationPlayer = $LabelAnimations

var queue = [] # List of cave depths, in the order they should be displayed

# Updates the label text to display the next depth value in the queue,
# then removes the value from the queue
func _process(delta):
	if queue and not animations.is_playing():
		label.text = "Cave Depth\n" + str(queue[0])
		animations.play("Show")
		queue.pop_front()

# Adds a depth value to the queue, if it does not already exist in the queue
func add_depth_to_queue(depth: int):
	if not depth in queue:
		queue.append(depth)
