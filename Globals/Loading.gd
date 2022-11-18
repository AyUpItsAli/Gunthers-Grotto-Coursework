extends Node

# Node references
onready var loading_screen = Overlay.get_node("LoadingScreen")
onready var loading_screen_anim = Overlay.get_node("LoadingScreen/Animations")

# Variables
onready var current_scene: Node = get_parent().get_child(get_parent().get_child_count() - 1)
var loading_thread := Thread.new()

func is_showing() -> bool:
	return loading_screen.visible

func show():
	loading_screen_anim.play("Fade_In")
	yield(loading_screen_anim, "animation_finished")

func hide():
	loading_screen_anim.play("Fade_Out")
	yield(loading_screen_anim, "animation_finished")

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
