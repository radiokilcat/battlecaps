extends Node
class_name StateMachine

@export var start_state: String = ""
var current: StateBase = null

func _ready():
	for c in get_children():
		if c is StateBase:
			c.sm = self
			c.connect("request_transition", _on_request_transition)
	if start_state != "":
		transition_to(start_state)

func transition_to(name: String, data := {}):
	if current:
		current._exit()
		set_process(false)
		set_process_input(false)
	var next := get_node_or_null(name)
	if next and next is StateBase:
		current = next
		current._enter(data)
		set_process(true)
		set_process_input(true)
	else:
		push_warning("State '%s' not found under %s" % [name, name])

func _process(delta):
	if current:
		current._process_state(delta)

func _input(event):
	if current:
		current._input_state(event)

func _on_request_transition(next_name: String):
	transition_to(next_name)
