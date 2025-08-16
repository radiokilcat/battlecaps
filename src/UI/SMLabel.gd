extends Label

@export var match_sm: Node
@export var turn_sm: Node

func _process(_delta):
	var match_state = match_sm.current.name if match_sm and match_sm.current else "?"
	var turn_state = turn_sm.current.name if turn_sm and turn_sm.current else "?"
	text = "Match: %s | Turn: %s" % [match_state, turn_state]
