# PlayerController.gd
extends Node

@export var active_cap: RigidBody3D
@export var camera_3d_path: NodePath    # Камера для raycast из курсора
@export var max_drag: float = 3.0
@export var min_power: float = 0.1
@export var max_power: float = 1.0

var aim_dir: Vector3 = Vector3.FORWARD
var power: float = 0.0
var _dragging := false

@onready var _cam: Camera3D = get_node_or_null(camera_3d_path)

func _get_active_cap() -> RigidBody3D: return active_cap
func get_aim_dir() -> Vector3: return aim_dir
func get_power() -> float: return power

func begin_aim_power() -> void:
	_dragging = false
	power = 0.0

func aim_power_input(event: InputEvent) -> bool:
	if not active_cap or not _cam: return false

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			power = 0.0
			return false
		else:
			# Отпустили — подтверждение
			_dragging = false
			return true

	if _dragging and event is InputEventMouseMotion:
		var world_point = _mouse_to_plane(event.position)
		var dir_vec = world_point - active_cap.global_position
		# Игнорируем вертикаль, если нужна плоскость XZ
		dir_vec.y = 0.0
		if dir_vec.length() > 0.0001:
			aim_dir = dir_vec.normalized()
			var dist = clamp(dir_vec.length(), 0.0, max_drag)
			power = clamp(dist / max_drag, min_power, max_power)
	return false

func shoot() -> void:
	if not active_cap: return
	var impulse = aim_dir.normalized() * lerp(3.0, 12.0, power)
	active_cap.apply_impulse(impulse)

# --- помогаем лучом попасть в плоскость XZ на высоте капсы ---
func _mouse_to_plane(screen_pos: Vector2) -> Vector3:
	var from = _cam.project_ray_origin(screen_pos)
	var dir  = _cam.project_ray_normal(screen_pos)
	# плоскость на высоте Y капсы
	var plane_y = active_cap.global_position.y
	var t = (plane_y - from.y) / dir.y if absf(dir.y) > 1e-6 else 0.0
	return from + dir * max(t, 0.0)
