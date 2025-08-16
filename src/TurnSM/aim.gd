extends StateBase

@export var max_drag: float = 3.0        # расстояние в мировых единицах, соответствующее 100% силы
@export var min_power: float = 0.1       # нижняя граница, чтобы не было нулевых тычков
@export var max_power: float = 1.0

var _confirmed := false

func _enter(_data := {}) -> void:
	_confirmed = false
	if "ui_arrow" in sm and sm.ui_arrow: sm.ui_arrow.visible = true
	if "ui_power" in sm and sm.ui_power: sm.ui_power.visible = true

	# Сообщаем контроллеру, что началась комбинированная фаза
	if "controller" in sm and sm.controller and sm.controller.has_method("begin_aim_power"):
		sm.controller.begin_aim_power()

	_update_ui()

func _exit() -> void:
	# UI прячется в Shoot
	pass

func _input_state(event: InputEvent) -> void:
	if not ("controller" in sm) or not sm.controller:
		return

	# Передаём событие контроллеру. Он обновляет aim_dir и power.
	if sm.controller.has_method("aim_power_input"):
		var done: bool = sm.controller.aim_power_input(event)
		if done and not _confirmed:
			_confirmed = true
			emit_signal("request_transition", "Shoot")

func _process_state(_delta: float) -> void:
	_update_ui()

# --------- helpers ----------

func _active_cap() -> Node:
	if sm.controller and sm.controller.has_method("_get_active_cap"):
		return sm.controller._get_active_cap()
	elif sm.controller and sm.controller.has_variable("active_cap"):
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
	var start: Vector3 = cap.global_position if ("global_position" in cap) else Vector3.ZERO
	var dir := _aim_dir().normalized()
	var p: float = clamp(_power(), min_power, max_power)

	# Обновление стрелки/траектории (длина/прозрачность ~ силе)
	if "ui_arrow" in sm and sm.ui_arrow:
		if sm.ui_arrow.has_method("set_from"):            # предпочтительный контракт
			sm.ui_arrow.set_from(start, dir, p)
		elif sm.ui_arrow.has_method("update_from"):
			sm.ui_arrow.update_from(start, dir, p)
		elif sm.ui_arrow is Node3D:
			sm.ui_arrow.global_position = start
			sm.ui_arrow.look_at(start + dir, Vector3.UP)
			# опционально масштаб по оси вперёд, если модель стрелки вытянута вдоль Z
			if ("scale" in sm.ui_arrow):
				var s = sm.ui_arrow.scale
				sm.ui_arrow.scale = Vector3(s.x, s.y, lerp(0.5, 2.5, p))

	# Полоска силы (если есть)
	if "ui_power" in sm and sm.ui_power and ("value" in sm.ui_power):
		sm.ui_power.value = p * 100.0
