extends StateBase

func _enter(_data = {}):
	var score = $"../../ScoreManager"
	score.call("update_after_turn")
	await get_tree().create_timer(1.0).timeout
	(sm as Node).emit_signal("turn_finished")
