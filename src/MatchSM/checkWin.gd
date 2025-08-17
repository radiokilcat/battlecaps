extends StateBase

func _enter(_data := {}) -> void:
	var score := $"../../ScoreManager" as ScoreManager
	if score == null:
		push_error("CheckWin: ScoreManager not found or script not attached.")
		return

	if score.is_game_over():
		print("Game over detected, transitioning to End state")
		emit_signal("request_transition", "End")
		return

	var last := String(score.current_player)
	var next_state := "NpcTurn" if last == "Player" else "PlayerTurn"

	print("Checking for win conditions → next:", next_state)
	emit_signal("request_transition", next_state)
