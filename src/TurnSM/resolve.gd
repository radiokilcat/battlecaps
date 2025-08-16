extends StateBase

func _enter(_data = {}):
	var score = $"../../ScoreManager"
	score.call("update_after_turn")
	# Если есть бонусный удар/рестрайк — можно ветвить здесь
	# Иначе — завершить ход:
	(sm as Node).emit_signal("turn_finished")
