extends StateMachine
class_name TurnSM

var controller: Node = null

signal turn_finished

@onready var physics_watcher: Node = $"../PhysicsManager"
#@onready var ui_arrow: Node = $"../UI/Arrow"
#@onready var ui_power: Node = $"../UI/PowerBar"

func set_controller(c: Node) -> void:
	controller = c
