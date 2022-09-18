extends Sprite

func _ready():
	# Hide the default mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$CursorAnimations.play("CursorIdle")

func _process(delta):
	# Get mouse's position relative to the viewport, NOT the world
	position = get_viewport().get_mouse_position()
