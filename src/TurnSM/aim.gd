extends StateBase

@export var max_drag: float = 3.0        # расстояние в мировых единицах, соответствующее 100% силы
@export var min_power: float = 0.1       # нижняя граница, чтобы не было нулевых тычков
@export var max_power: float = 1.0

var _confirmed := false
var _signals_bound := false

func _enter(_data := {}) -> void:
	_confirmed = false
	if sm.controller and sm.controller.has_method("arm_to_start"):
		sm.controller.arm_to_start()
	if sm.controller is NpcController:
		sm.controller.start_charge()

	if "ui_arrow" in sm and sm.ui_arrow: sm.ui_arrow.visible = true
	if "ui_power" in sm and sm.ui_power: sm.ui_power.visible = true


	_update_ui()

func _exit() -> void:
	if sm.controller and sm.controller.has_method("cancel_charge"):
		sm.controller.cancel_charge()
	pass

func _input_state(event: InputEvent) -> void:
	if not sm.controller or sm.controller is NpcController:
		return
	if event and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			sm.controller.start_charge()
		else:
			sm.controller.shoot()
			sm.transition_to("Shoot")
	

func _bind_signals(connect_now: bool) -> void:
	if not sm.controller:
		return
	if connect_now and not _signals_bound:
		if sm.controller.has_signal("shot_fired"):
			sm.controller.shot_fired.connect(_on_shot_fired)
		_signals_bound = true
	elif not connect_now and _signals_bound:
		if sm.controller.is_connected("shot_fired", _on_shot_fired):
			sm.controller.shot_fired.disconnect(_on_shot_fired)
		_signals_bound = false

func _on_shot_fired(_impulse: Vector3) -> void:
	sm.controller.shoot()
	sm.transition_to("Shoot")

# func _process_state(_delta: float) -> void:
	# if _charging:
	# 	_charge_t = clampf(_charge_t + delta, 0.0, max_charge_time)
	# 	var power := _charge_t / max_charge_time
	# 	_emit_power_ui(power)
	# 	_update_aim_dir()
	# _update_ui()

func _active_cap() -> Node:
	if sm.controller and sm.controller.has_method("_get_active_cap"):
		return sm.controller._get_active_cap()
	elif sm.controller and "active_cap" in sm.controller:
		return sm.controller.active_cap
	return null

func _aim_dir() -> Vector3:
	return sm.controller.get_aim_dir() if sm.controller and sm.controller.has_method("get_aim_dir") else (
		sm.controller.aim_dir if ("aim_dir" in sm.controller) else Vector3.FORWARD
	)

func _power() -> float:
	return sm.controller.get_power() if sm.controller and sm.controller.has_method("get_power") else (
		sm.controller.power if ("power" in sm.controller) else 0.0
	)

func _update_ui() -> void:
	var cap := _active_cap()
	if not cap: return
	# var start: Vector3 = cap.global_position if ("global_position" in cap) else Vector3.ZERO
	# var dir := _aim_dir().normalized()
	# var p: float = clamp(_power(), min_power, max_power)

	# Обновление стрелки/траектории (длина/прозрачность ~ силе)
	# if "ui_arrow" in sm and sm.ui_arrow:
	# 	if sm.ui_arrow.has_method("set_from"):
	# 		sm.ui_arrow.set_from(start, dir, p)
	# 	elif sm.ui_arrow.has_method("update_from"):
	# 		sm.ui_arrow.update_from(start, dir, p)
	# 	elif sm.ui_arrow is Node3D:
	# 		sm.ui_arrow.global_position = start
	# 		sm.ui_arrow.look_at(start + dir, Vector3.UP)
	# 		if ("scale" in sm.ui_arrow):
	# 			var s = sm.ui_arrow.scale
	# 			sm.ui_arrow.scale = Vector3(s.x, s.y, lerp(0.5, 2.5, p))

	# # Полоска силы (если есть)
	# if "ui_power" in sm and sm.ui_power and ("value" in sm.ui_power):
	# 	sm.ui_power.value = p * 100.0
