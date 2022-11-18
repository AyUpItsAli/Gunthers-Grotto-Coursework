extends Node2D

onready var label: Label = $Label
onready var animations: AnimationPlayer = $Animations

var title_queue = [] # List of titles to be displayed

# Updates the label text to display the next title in the queue,
# then removes the title from the queue
func _process(delta):
	if title_queue and not animations.is_playing():
		label.text = title_queue[0]
		animations.play("Show")
		title_queue.pop_front()

# Adds a title to the title queue
func add_title_to_queue(title: String):
	if not title in title_queue:
		title_queue.append(title)
