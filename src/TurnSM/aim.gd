class_name AimPower
extends StateBase

signal charge_started
signal charge_changed(power: float)
signal charge_released(power: float)
signal charge_canceled



@export var charge_time: float = 1.2	# Сколько секунд до полного заряда (1.0)
@export var use_curve: bool = false		# Включить кривую (например, быстрый старт)
@export var charge_curve: Curve			# По желанию — назначь кривую в инспекторе
@export var max_drag: float = 3.0        # расстояние в мировых единицах, соответствующее 100% силы
@export var min_power: float = 0.1       # нижняя граница, чтобы не было нулевых тычков
@export var max_power: float = 1.0

var _confirmed := false
var _signals_bound := false
var _charging: bool = false
var _t: float = 0.0						# Накопленное время [0..charge_time]
var _power: float = 0.0					# Текущий заряд [0..1]
var _controller: Node = null			# Ссылка от TurnSM

func _enter(_data := {}) -> void:
	_confirmed = false
	if sm.controller and sm.controller.has_method("arm_to_start"):
		sm.controller.arm_to_start()
		# sm.controller.connect("charge_released", Callable(self, "_on_charge_released"))
	if sm.controller is NpcController:
		sm.controller.start_charge()

	if "ui_arrow" in sm and sm.ui_arrow: sm.ui_arrow.visible = true
	if "ui_power" in sm and sm.ui_power: sm.ui_power.visible = true


	# _update_ui()

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

func power() -> float:
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


func _on_npc_controller_shot_fired(impulse: Vector3) -> void:
	sm.controller.shoot()
	sm.transition_to("Shoot")
