extends Node
class_name StateBase

signal request_transition(next_state_name: String)

var sm: Node = null

func _enter(_data := {})->void: pass
func _exit()->void: pass
func _process_state(_delta: float)->void: pass
func _input_state(_event: InputEvent)->void: pass
