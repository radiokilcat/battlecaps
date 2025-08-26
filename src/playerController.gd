# PlayerController.gd
extends Node

signal power_changed(value: float)
signal charge_started()
signal charge_released(value: float)
signal shot_fired(impulse: Vector3)

@export var max_charge_time: float = 1.2
@export var min_impulse: float = 3.0
@export var max_impulse: float = 12.0

@export var active_cap: RigidBody3D
@export var camera_3d_path: NodePath
@export var max_drag: float = 3.0
@export var min_power: float = 0.1
@export var max_power: float = 1.0

var aim_dir: Vector3 = Vector3.FORWARD
var power: float = 0.0
var _dragging := false
var _is_charging: bool = false
var _charge_t: float = 0.0

@onready var _cam: Camera3D = get_node_or_null(camera_3d_path)

func _get_active_cap() -> RigidBody3D: return active_cap
func get_aim_dir() -> Vector3: return aim_dir
func get_power() -> float: return power

func arm_to_start() -> void:
	if active_cap == null: return
	if active_cap.has_method("reset_to_start"):
		active_cap.reset_to_start()
	if active_cap.has_method("set_active"):
		active_cap.set_active()

func start_charge() -> void:
	_dragging = false
	power = 0.0
	_is_charging = true
	_charge_t = 0.0
	power = 0.0
	set_process(true)
	emit_signal("charge_started")
	emit_signal("power_changed", power)

func cancel_charge() -> void:
	_is_charging = false
	set_process(false)

func _process(delta: float) -> void:
	if _is_charging:
		_charge_t = clampf(_charge_t + delta, 0.0, max_charge_time)
		power = _charge_t / max_charge_time
		emit_signal("power_changed", power)

func aim_power_input(event: InputEvent) -> bool:
	if not active_cap or not _cam: return false

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			power = 0.0
			return false
		else:
			_dragging = false
			return true

	if _dragging and event is InputEventMouseMotion:
		var world_point = _mouse_to_plane(event.position)
		var dir_vec = world_point - active_cap.global_position
		dir_vec.y = 0.0
		if dir_vec.length() > 0.0001:
			aim_dir = dir_vec.normalized()
			var dist = clamp(dir_vec.length(), 0.0, max_drag)
			power = clamp(dist / max_drag, min_power, max_power)
	return false

func shoot() -> void:
	_is_charging = false
	set_process(false)

	var p := clampf(power, 0.0, 1.0)
	var impulse_strength: float = lerp(min_impulse, max_impulse, p)
	var impulse: Vector3 = aim_dir.normalized() * impulse_strength

	if active_cap:
		active_cap.apply_impulse(impulse)

	emit_signal("charge_released", p)
	emit_signal("shot_fired", impulse)

func _mouse_to_plane(screen_pos: Vector2) -> Vector3:
	var from = _cam.project_ray_origin(screen_pos)
	var dir  = _cam.project_ray_normal(screen_pos)
	var plane_y = active_cap.global_position.y
	var t = (plane_y - from.y) / dir.y if absf(dir.y) > 1e-6 else 0.0
	return from + dir * max(t, 0.0)
