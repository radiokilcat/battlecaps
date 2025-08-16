extends StateBase

func _enter(_data = {}):
	var score := $"../../ScoreManager"
	score.begin_turn("NPC")
	var turn_sm: Node = $"../../TurnSM"
	turn_sm.visible = true
	turn_sm.set_process(true)
	turn_sm.set_process_input(true)
	turn_sm.call("set_controller", $"../../NpcController")
	turn_sm.set_controller($"../../NpcController")
	turn_sm.turn_finished.connect(_on_turn_finished, CONNECT_ONE_SHOT)

func _exit():
	var turn_sm: Node = $"../../TurnSM"
	turn_sm.set_process(false)
	turn_sm.set_process_input(false)
	turn_sm.visible = false

func _on_turn_finished():
	emit_signal("request_transition", "CheckWin")
