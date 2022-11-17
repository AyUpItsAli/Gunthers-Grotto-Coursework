class_name StateMachine
extends Node

var current_state: Node
var previous_state_name: String

func _ready():
	yield(owner, "ready")
	for state in get_children():
		state.init(self)
	var initial_state = get_child(0)
	enter_state(initial_state.name)

func _process(delta):
	current_state.update(delta)

func _physics_process(delta):
	current_state.physics_update(delta)

func _unhandled_input(event):
	current_state.handle_input(event)

func enter_state(new_state: String, ctx: Dictionary = {}):
	if not has_node(new_state): return
	if current_state:
		previous_state_name = current_state.name
		current_state.exit()
	current_state = get_node(new_state)
	current_state.enter(ctx)

func enter_previous_state(ctx: Dictionary = {}):
	enter_state(previous_state_name, ctx)

func is_state(state: String) -> bool:
	return current_state.name == state

func call_method(method: String, args: Array = []):
	if current_state.has_method(method):
		current_state.callv(method, args)
