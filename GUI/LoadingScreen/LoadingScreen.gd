extends CanvasLayer

onready var background: ColorRect = $Background
onready var animations: AnimationPlayer = $Animations
onready var current_scene = get_parent().get_child(get_parent().get_child_count() - 1)

var loading_thread := Thread.new()

func load_scene(path):
	if loading_thread.is_active(): return
	animations.play("Fade_In")
	yield(animations, "animation_finished")
	loading_thread.start(self, "_load_scene", path)

# Called on the loading thread
func _load_scene(path):
	current_scene.queue_free()
	var scene = ResourceLoader.load(path).instance()
	call_deferred("post_scene_loaded")
	return scene

# Called on the main thread,
# after the loading thread has finished loading the scene
func post_scene_loaded():
	current_scene = loading_thread.wait_to_finish()
	get_node("/root").add_child(current_scene)
