extends Node

@export var active_cap: RigidBody3D
var aim_dir: Vector3 = Vector3.FORWARD
var power: float = 0.6

func _get_active_cap() -> RigidBody3D: return active_cap
func get_aim_dir() -> Vector3: return aim_dir
func get_power() -> float: return power

func begin_aim_power() -> void:
	# простая логика — в сторону ближайшей капсы из группы "caps"
	var best := _pick_target_dir()
	aim_dir = best
	power = 0.6

func aim_power_input(_e) -> bool:
	return true

func shoot() -> void:
	if not active_cap: return
	active_cap.apply_impulse(aim_dir.normalized() * lerp(3.0, 12.0, power))

func _pick_target_dir() -> Vector3:
	var caps = get_tree().get_nodes_in_group("caps")
	var pos = active_cap.global_position
	var best: Node = null
	var best_d := INF
	for c in caps:
		if c == active_cap: continue
		var d = pos.distance_to(c.global_position)
		if d < best_d:
			best_d = d
			best = c
	if best:
		var v = best.global_position - pos
		v.y = 0.0
		return v.normalized()
	return Vector3.FORWARD
