extends StateBase

func _enter(_data = {}):
	var score := $"../../ScoreManager" as ScoreManager
	var watcher: PhysicsWatcher = sm.physics_watcher
	var knocked_caps: Array = []
	if watcher:
		knocked_caps = watcher.consume_new_knockouts()
	if score:
		for cap in knocked_caps:
			score.register_knockout(cap)
	if score:
		score.update_after_turn()
	else:
		push_warning("Resolve: ScoreManager not found.")
	await get_tree().create_timer(1.0).timeout
	(sm as Node).emit_signal("turn_finished")
