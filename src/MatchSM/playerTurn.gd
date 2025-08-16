extends StateBase

@onready var turn_sm: TurnSM = $"../../TurnSM" as TurnSM
@onready var score: ScoreManager = $"../../ScoreManager" as ScoreManager
@onready var player_controller: Node = $"../../PlayerController"

func _enter(_data = {}):
	score.begin_turn("Player")
	turn_sm.set_controller(player_controller)
	turn_sm.set_process(true)
	turn_sm.set_process_input(true)
	turn_sm.call("set_controller", $"../../PlayerController")
	turn_sm.turn_finished.connect(_on_turn_finished, CONNECT_ONE_SHOT)

func _exit():
	# на выходе можно выключить TurnSM, если надо
	var turn_sm: Node = $"../../TurnSM"
	turn_sm.set_process(false)
	turn_sm.set_process_input(false)

func _on_turn_finished():
	emit_signal("request_transition", "NpcTurn")
