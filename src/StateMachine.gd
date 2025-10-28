extends Node
class_name StateMachine

signal state_changed(name: String)

@export var start_state: String = ""
var current: StateBase = null

func _ready():
	for c in get_children():
		_bind_state(c)

	child_entered_tree.connect(_on_child_entered_tree)

	if start_state != "":
		call_deferred("transition_to", start_state)

func _on_child_entered_tree(node: Node) -> void:
	_bind_state(node)

func _bind_state(n: Node) -> void:
	if n is StateBase:
		var s := n as StateBase
		s.sm = self
		if not s.request_transition.is_connected(_on_request_transition):
			s.request_transition.connect(_on_request_transition)

func transition_to(name: String, data := {}):
	if current:
		current._exit()
	var next := get_node_or_null(name)
	if next and next is StateBase:
		current = next
		state_changed.emit(current.name)
		current._enter(data)
		set_process(true)
		set_process_input(true)
	else:
		push_warning("State '%s' not found under %s" % [name, name])

func _process(delta): if current: current._process_state(delta)
func _input(event):   if current: current._input_state(event)
func _on_request_transition(next_name: String): transition_to(next_name)
