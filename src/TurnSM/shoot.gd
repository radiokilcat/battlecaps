extends StateBase

func _enter(_data = {}):
	# sm.ui_arrow.visible = false
	# sm.ui_power.visible = false
	sm.controller.call("shoot")   # применяет импульс к активной капсе
	await get_tree().create_timer(2.0).timeout
	emit_signal("request_transition", "WaitStop")
