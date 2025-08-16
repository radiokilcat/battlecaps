extends StateBase

func _enter(_data = {}):
	sm.physics_watcher.call("start_watch")

func _process_state(_delta):
	if sm.physics_watcher.call("all_caps_stopped"):
		emit_signal("request_transition", "Resolve")
