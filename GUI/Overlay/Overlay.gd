extends CanvasLayer

onready var cursor: Sprite = $Cursor

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	cursor.get_node("Animations").play("Cursor_Spinning")

func _process(delta):
	cursor.position = get_viewport().get_mouse_position()
