extends Camera2D

const ZOOM_FACTOR = Vector2(0.1,0.1)
var panning: bool

func _process(delta):
	panning = Input.is_action_pressed("mouse_pan")
	
func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		zoom -= ZOOM_FACTOR * zoom
	elif event.is_action_pressed("zoom_out"):
		zoom += ZOOM_FACTOR * zoom
	
	if event is InputEventMouseMotion:
		if panning:
			global_position -= event.relative * zoom
