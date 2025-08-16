extends StateBase

func _enter(_data = {}):
	var score := $"../../ScoreManager"
	if score.call("is_game_over"):
		emit_signal("request_transition", "End")
	else:
		# чередование ходов: вернёмся к игроку
		emit_signal("request_transition", "PlayerTurn")
