extends CanvasLayer

onready var background: ColorRect = $Background
onready var background_animations: AnimationPlayer = $Background/Animations
onready var cursor: Sprite = $Cursor
onready var cursor_animations: AnimationPlayer = $Cursor/Animations

onready var current_scene: Node = get_parent().get_child(get_parent().get_child_count() - 1)
var loading_thread := Thread.new()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	background.visible = false
	cursor_animations.play("Cursor_Spinning")

func _process(delta):
	cursor.position = get_viewport().get_mouse_position()

func is_showing():
	return background.visible

func show():
	# TODO: Better solution for when loading screen is already showing
	if is_showing(): return yield(get_tree(), "idle_frame")
	background_animations.play("Fade_In")
	yield(background_animations, "animation_finished")

func hide():
	if not is_showing(): return yield(get_tree(), "idle_frame")
	background_animations.play("Fade_Out")
	yield(background_animations, "animation_finished")

func change_scene(scene_path):
	if loading_thread.is_active(): return
	yield(show(), "completed")
	current_scene.queue_free()
	loading_thread.start(self, "_load_scene_resource", scene_path)

func _load_scene_resource(scene_path):
	var scene_resource = ResourceLoader.load(scene_path)
	call_deferred("instanciate_new_scene")
	return scene_resource

func instanciate_new_scene():
	var scene_resource = loading_thread.wait_to_finish()
	current_scene = scene_resource.instance()
	get_node("/root").add_child(current_scene)
