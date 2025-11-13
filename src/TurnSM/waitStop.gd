extends StateBase

func _enter(_data = {}):
	var watcher: PhysicsWatcher = sm.physics_watcher
	if watcher:
		watcher.start_watch()

func _process_state(_delta):
	var watcher: PhysicsWatcher = sm.physics_watcher
	if watcher and watcher.all_caps_stopped():
		emit_signal("request_transition", "Resolve")
