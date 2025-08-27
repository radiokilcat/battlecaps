extends Node
class_name NpcController

signal power_changed(value: float)
signal charge_started()
signal charge_released(value: float)
signal shot_fired(impulse: Vector3)

@export var min_impulse: float = 3.0
@export var max_impulse: float = 12.0

# Сколько в сумме занимает зарядка до 100% (рандомный «темп» зарядки)
@export var charge_time_range: Vector2 = Vector2(0.9, 1.4)

# На каком проценте «отпускать» (рандом: от X до Y). 0.4..1.0 = 40%..100%
@export var shoot_power_range: Vector2 = Vector2(0.6, 1.0)

# Авто-обновление aim_dir на лету, если задана цель/нода
@export var keep_aim_updated: bool = true

var active_cap: RigidBody3D
var aim_dir: Vector3 = Vector3.ZERO
var power: float = 0.0					# [0..1], единый источник правды

var _is_charging: bool = false
var _charge_t: float = 0.0
var _total_charge_time: float = 1.0
var _shoot_at_time: float = 0.7			# момент авто-выстрела (сек) в рамках текущего цикла зарядки

var _target_point: Vector3 = Vector3.ZERO
var _target_node: Node3D = null

@onready var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	set_process(false)

func start_charge() -> void:
	_is_charging = true
	_charge_t = 0.0
	power = 0.0

	_total_charge_time = clampf(_rng.randf_range(charge_time_range.x, charge_time_range.y), 0.1, 10.0)
	var desired_power := clampf(_rng.randf_range(shoot_power_range.x, shoot_power_range.y), 0.0, 1.0)
	_shoot_at_time = desired_power * _total_charge_time

	set_process(true)
	emit_signal("charge_started")
	emit_signal("power_changed", power)

func cancel_charge() -> void:
	_is_charging = false
	set_process(false)

func _process(delta: float) -> void:
	if not _is_charging:
		return

	_charge_t = min(_charge_t + delta, _total_charge_time)
	power = _charge_t / _total_charge_time
	emit_signal("power_changed", power)

	if keep_aim_updated:
		_update_aim_dir_from_target()

	if _charge_t >= _shoot_at_time:
		cancel_charge()
		emit_signal("shot_fired", power)

# Контракт: применяет импульс исходя из текущих aim_dir и power
func shoot() -> void:
	if not _is_charging:
		return
	_is_charging = false
	set_process(false)

	var p := clampf(power, 0.0, 1.0)
	var impulse_strength: float = lerp(min_impulse, max_impulse, p)

	var dir := aim_dir
	if dir == Vector3.ZERO:
		_update_aim_dir_from_target()
		dir = aim_dir

	if active_cap and dir != Vector3.ZERO:
		var impulse := dir.normalized() * impulse_strength
		active_cap.apply_impulse(impulse)
		emit_signal("charge_released", p)
		emit_signal("shot_fired", impulse)
	else:
		emit_signal("charge_released", p)
		emit_signal("shot_fired", Vector3.ZERO)


func set_target_point(point: Vector3) -> void:
	_target_point = point
	_target_node = null

func set_target_node(node: Node3D) -> void:
	_target_node = node

func _update_aim_dir_from_target() -> void:
	if active_cap == null:
		return
	var tgt := _target_point
	if _target_node:
		tgt = _target_node.global_position
	var to := (tgt - active_cap.global_position).project(Vector3(1, 0, 1))
	if to.length() > 0.001:
		aim_dir = to.normalized()
